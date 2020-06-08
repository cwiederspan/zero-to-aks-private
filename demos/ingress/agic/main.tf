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

variable "namespace" {
  type        = string
  description = "The namespace where the sample application will be installed."
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

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "app" {
  name       = "hello-world-app"
  repository = "https://cdwmshelm.z5.web.core.windows.net"
  chart      = "shared-chart"
  version    = "1.0.0"
  namespace = kubernetes_namespace.namespace.metadata[0].name

  set {
    name  = "fullname"
    value = "hello-world-application"
  }

  set {
    name  = "name"
    value = "hello-world"
  }

  set {
    name  = "image.repository"
    value = "appsvcsample/python-helloworld"
  }

  set {
    name  = "image.tag"
    value = "latest"
  }

  set {
    name  = "nodeSelector.beta\\.kubernetes\\.io/os"
    value = "linux"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "service.port"
    value = 80
  }

  set {
    name  = "service.targetPort"
    value = "http"
  }

  set {
    name  = "service.protocol"
    value = "TCP"
  }

  set {
    name  = "service.portName"
    value = "http"
  }

  set {
    name  = "probes.enabled"
    value = false
  }

  set {
    name  = "ingress.enabled"
    value = true
  }

  set {
    name  = "ingress.hosts[0].paths[0]"
    value = "/helloworld"
  }

  set {
    name  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "azure/application-gateway"
  }
}
