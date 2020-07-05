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

variable "aks_rg" {
  type        = string
  description = "The name of the resource group where the AKS cluster resides."
}

variable "aks_name" {
  type        = string
  description = "The name of the AKS cluster to access."
}

variable "flux_namespace" {
  type        = string
  description = "The namespace where flux will be installed."
  default     = "flux"
}

variable "flux_repo" {
  type        = string
  description = "The git repo from which flux will deploy manifests."
}

data "azurerm_kubernetes_cluster" "aks" {
  resource_group_name = var.aks_rg
  name                = var.aks_name
}

resource "kubernetes_namespace" "flux" {
  metadata {
    name = var.flux_namespace
  }
}

resource "helm_release" "flux" {
  name      = "flux"
  repository = "https://charts.fluxcd.io"
  chart     = "flux"
  #version = "3.3.3"
  namespace = kubernetes_namespace.flux.metadata[0].name

  set {
    name  = "git.url"
    value = var.flux_repo
  }
}

resource "helm_release" "helm-operator" {
  name      = "helm-operator"
  repository = "https://charts.fluxcd.io"
  chart     = "helm-operator"
  #version = "3.3.3"
  namespace = kubernetes_namespace.flux.metadata[0].name

  set {
    name  = "git.ssh.secretName"
    value = "flux-git-deploy"
  }
  
  set {
    name  = "helm.versions"
    value = "v3"
  }

  depends_on = [
    helm_release.flux
  ]
}