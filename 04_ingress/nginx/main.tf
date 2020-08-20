terraform {
  required_version = ">= 0.12"
  
  backend "azurerm" {
    environment = "public"
  }
}

provider "azurerm" {
  version = "~> 2.24"
  features {}
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

variable "ingress_namespace" {
  type        = string
  description = "The namespace where the ingress controller will be installed."
}

variable "aks_rg" {
  type        = string
  description = "The name of the resource group where the AKS cluster resides."
}

variable "aks_name" {
  type        = string
  description = "The name of the AKS cluster to access."
}

data "azurerm_kubernetes_cluster" "aks" {
  resource_group_name = var.aks_rg
  name                = var.aks_name
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = var.ingress_namespace
  }
}

resource "helm_release" "ingress" {
  name      = "nginx-ingress"
  repository = "https://helm.nginx.com/stable"
  chart     = "nginx-ingress"
  #version = "3.3.3"
  namespace = kubernetes_namespace.ingress.metadata[0].name

  set {
    name  = "controller.replicaCount"
    value = 2
  }

  set {
    name  = "controller.healthStatus"
    value = "true"
  }

  set {
    name  = "controller.nodeSelector.beta\\.kubernetes\\.io/os"
    value = "linux"
  }

  set {
    name  = "defaultBackend.nodeSelector.beta\\.kubernetes\\.io/os"
    value = "linux"
  }
}
