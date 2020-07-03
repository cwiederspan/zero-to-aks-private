terraform {
  required_version = ">= 0.12"
  
  backend "azurerm" {
    environment = "public"
  }
}

provider "azurerm" {
  version = "~> 2.17"
  features {}
}

provider "azuread" {
  version = "~> 0.10"
}

provider "kubernetes" {
  version = "~> 1.11"
}

provider "helm" {
  version = "~> 1.2"

  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

variable "base_name" {
  type        = string
  description = "The base naming scheme to use when creating resources."
}

variable "aks_rg" {
  type        = string
  description = "The name of the resource group where the AKS cluster resides."
}

variable "aks_name" {
  type        = string
  description = "The name of the AKS cluster to access."
}

variable "vnet_rg" {
  type        = string
  description = "The name resource group where the vnet lives."
}

variable "vnet_name" {
  type        = string
  description = "The name of the vnet to create the cluster within."
}

variable "cluster_subnet_name" {
  type        = string
  description = "The subnet within the vnet where the cluster lives."
}

variable "ingress_subnet_name" {
  type        = string
  description = "The subnet within the vnet to create the ingress gateway within."
}

variable "ingress_namespace" {
  type        = string
  description = "The namespace where the ingress controller will be installed."
}

variable "gateway_instance_count" {
  type        = number
  description = "The number of instances to scale the App Gateway."
  default     = 1
}

locals {
  msi_name                       = "${var.base_name}-msi"
  gateway_ip_name                = "${var.base_name}-ip"
  gateway_ip_config_name         = "${var.base_name}-ipconfig"
  frontend_port_name             = "${var.base_name}-feport"
  frontend_ip_configuration_name = "${var.base_name}-feip"
  backend_address_pool_name      = "${var.base_name}-bepool"
  http_setting_name              = "${var.base_name}-http"
  listener_name                  = "${var.base_name}-lstn"
  request_routing_rule_name      = "${var.base_name}-router"
}

data "azurerm_subscription" "current" { }

data "azurerm_resource_group" "group" {
  name = var.aks_rg
}

data "azurerm_kubernetes_cluster" "aks" {
  resource_group_name = var.aks_rg
  name                = var.aks_name
}

data "azuread_service_principal" "sp" {
  application_id = data.azurerm_kubernetes_cluster.aks.service_principal.0.client_id
}

data "azurerm_subnet" "ingress" {
  resource_group_name  = var.vnet_rg
  virtual_network_name = var.vnet_name
  name                 = var.ingress_subnet_name
}

data "azurerm_subnet" "cluster" {
  resource_group_name  = var.vnet_rg
  virtual_network_name = var.vnet_name
  name                 = var.cluster_subnet_name
}

resource "azurerm_user_assigned_identity" "msi" {
  resource_group_name = data.azurerm_kubernetes_cluster.aks.node_resource_group
  location            = data.azurerm_kubernetes_cluster.aks.location
  name                = local.msi_name
}

resource "azurerm_role_assignment" "ra1" {
  scope                = data.azurerm_subnet.cluster.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.sp.id
}

resource "azurerm_role_assignment" "ra2" {
  scope                = azurerm_user_assigned_identity.msi.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = data.azuread_service_principal.sp.id
}

resource "azurerm_role_assignment" "ra3" {
  scope                = azurerm_application_gateway.gateway.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.msi.principal_id
}

resource "azurerm_role_assignment" "ra4" {
  scope                = data.azurerm_resource_group.group.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.msi.principal_id
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = var.ingress_namespace
  }
}

resource "azurerm_public_ip" "ip" {
  name                = local.gateway_ip_name
  resource_group_name = data.azurerm_resource_group.group.name
  location            = data.azurerm_resource_group.group.location
  domain_name_label   = var.base_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "gateway" {
  name                = "${var.base_name}-appgw"
  resource_group_name = data.azurerm_resource_group.group.name
  location            = data.azurerm_resource_group.group.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = var.gateway_instance_count
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_config_name
    subnet_id = data.azurerm_subnet.ingress.id
  }

  frontend_port {
    name = "${local.frontend_port_name}-http"
    port = 80
  }

  frontend_port {
    name = "${local.frontend_port_name}-https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.ip.id
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "http"
    request_timeout       = 1
  }

  http_listener {
    name                           = "${local.listener_name}-http"
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "${local.frontend_port_name}-http"
    protocol                       = "http"
  }

  request_routing_rule {
    name               = "${local.request_routing_rule_name}-http"
    rule_type          = "Basic"
    http_listener_name = "${local.listener_name}-http"
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

resource "helm_release" "podid" {
  name       = "aad-pod-identity"
  repository = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts/"
  chart      = "aad-pod-identity"
  version    = "2.0.0"
  namespace  = "kube-system" # Per note here: https://github.com/Azure/aad-pod-identity/tree/master
}

resource "helm_release" "agic" {
  name       = "ingress-azure"
  repository = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
  chart      = "ingress-azure"
  version    = "1.2.0-rc3"
  namespace = kubernetes_namespace.ingress.metadata[0].name

  set {
    name  = "appgw.subscriptionId"
    value = data.azurerm_subscription.current.subscription_id
  }

  set {
    name  = "appgw.resourceGroup"
    value = azurerm_application_gateway.gateway.resource_group_name
  }

  set {
    name  = "appgw.name"
    value = azurerm_application_gateway.gateway.name
  }

  set {
    name  = "appgw.shared"
    value = "false"
  }

  set {
    name  = "armAuth.type"
    value = "aadPodIdentity"
  }

  set {
    name  = "armAuth.identityResourceID"
    value = azurerm_user_assigned_identity.msi.id
  }

  set {
    name  = "armAuth.identityClientID"
    value = azurerm_user_assigned_identity.msi.client_id
  }

  set {
    name  = "rbac.enabled"
    value = "true"
  }
}
