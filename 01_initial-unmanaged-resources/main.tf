terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
  version = "~> 2.10"
  features {}
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group that will be created."
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account that will be create (alphanumeric only)."
}

variable "blob_container_name"  {
  type        = string
  description = "The name of the blob container/folder will be create (alphanumeric only)."
}

variable "location"             {
  type        = string
  description = "The Azure region where the resources will be created."
}

resource "azurerm_resource_group" "group" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "account" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.group.name
  location                 = azurerm_resource_group.group.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "container" {
  name                  = var.blob_container_name
  storage_account_name  = azurerm_storage_account.account.name
  container_access_type = "private"
}

output "storage_account_name" {
  value = var.storage_account_name
}

output "container_name" {
  value = var.blob_container_name
}

output "key" {
  value = "state.tfstate"
}

output "access_key" {
  value = azurerm_storage_account.account.primary_access_key
}