terraform {
  required_version = ">= 0.12"
  
  backend "azurerm" {
    environment = "public"
  }
}

provider "azurerm" {
  version = "~> 2.13"
  features {}
}

variable "name_prefix" {
  type        = string
  description = "A prefix for the naming scheme as part of prefix-base-suffix."
}

variable "name_base" {
  type        = string
  description = "A base for the naming scheme as part of prefix-base-suffix."
}

variable "name_suffix" {
  type        = string
  description = "A suffix for the naming scheme as part of prefix-base-suffix."
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be created."
}

variable "aks_version" {
  type        = string
  description = "The Azure region where the resources will be created."
}

variable "node_count" {
  type        = number
  description = "The number of nodes to create in the default node pool."
  default     = 1
}

variable "node_vm_sku" {
  type        = string
  description = "The VM SKU to use for the default nodes."
  default     = "Standard_DS2_v2"
}

variable "win_admin_username" {
  type        = string
  description = "A username to use if/when creating a Windows node pool (must be added at cluster creation time)."
}

variable "win_admin_password" {
  type        = string
  description = "A password to use if/when creating a Windows node pool (must be added at cluster creation time)."
}

variable "vnet_rg_name" {
  type        = string
  description = "The name resource group where the vnet lives."
}

variable "vnet_name" {
  type        = string
  description = "The name of the vnet to create the cluster within."
}

variable "cluster_subnet_name" {
  type        = string
  description = "The subnet within the vnet to create the cluster within."
}

variable "authorized_ip_addresses" {
  type        = list(string)
  description = "A list of CIDR block strings that can access the Kubernetes API endpoint."
  default     = [ ]
}

variable "enable_azure_policy" {
  type        = bool
  description = "A flag for enabling Azure Policy for AKS (currently in Preview)."
  default     = false
}

locals {
  base_name = "${var.name_prefix}-${var.name_base}-${var.name_suffix}"
}

module "service_principal" {
  source    = "./modules/service-principal"
  base_name = local.base_name
}

module "monitoring" {
  source         = "./modules/monitoring"
  base_name      = local.base_name
  resource_group = azurerm_resource_group.group.name
  location       = azurerm_resource_group.group.location
}

data "azurerm_subnet" "cluster" {
  resource_group_name  = var.vnet_rg_name
  virtual_network_name = var.vnet_name
  name                 = var.cluster_subnet_name
}

resource "azurerm_resource_group" "group" {
  name     = local.base_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.base_name
  resource_group_name = azurerm_resource_group.group.name
  location            = azurerm_resource_group.group.location
  dns_prefix          = local.base_name
  kubernetes_version  = var.aks_version

  api_server_authorized_ip_ranges = var.authorized_ip_addresses

  default_node_pool {
    name       = "lnx000"
    node_count = var.node_count
    vm_size    = var.node_vm_sku
    # node_taints
    # node_labels

    # Required for advanced networking
    vnet_subnet_id = data.azurerm_subnet.cluster.id
  }

  windows_profile {
    admin_username = var.win_admin_username
    admin_password = var.win_admin_password
  }

  service_principal {
    client_id     = module.service_principal.client_id
    client_secret = module.service_principal.client_secret
  }

  role_based_access_control {
    enabled = true
  }
  
  addon_profile {
    
    azure_policy {
      enabled = var.enable_azure_policy
    }

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = module.monitoring.workspace_id
    }
    # http_application_routing {
    #   enabled = true
    # }
  }

  network_profile {
    network_plugin     = "azure"
    service_cidr       = "172.16.0.0/16"
    dns_service_ip     = "172.16.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  # lifecycle {
  #   prevent_destroy = true
  # }

  depends_on = [
    module.service_principal.client_id
  ]
}

resource "azurerm_kubernetes_cluster_node_pool" "winnodepool" {
  name                  = "win001"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  os_type               = "Windows"

  # Required for advanced networking
  vnet_subnet_id = data.azurerm_subnet.cluster.id
}

# output "client_id" {
#   value = module.service_principal.client_id
# }
