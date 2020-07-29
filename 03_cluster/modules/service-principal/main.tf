// Read more about why we're doing this
// https://github.com/terraform-providers/terraform-provider-azurerm/issues/2159

provider "azuread" {
  version = "~> 0.7"
}

provider "random" {
  version = "~> 2.2"
}

variable "base_name" { }

# Generate random string to be used as service principal password
resource "random_string" "password" {
  length  = 32
  special = true
}

# Create Azure AD Application for Service Principal
resource "azuread_application" "app" {
  name = "${var.base_name}-sp"
}

# Create Service Principal
resource "azuread_service_principal" "sp" {
  application_id = azuread_application.app.application_id
}

# Create Service Principal password
resource "azuread_service_principal_password" "pwd" {
  end_date             = "2299-12-30T23:00:00Z"                        # Forever
  service_principal_id = azuread_service_principal.sp.id
  value                = random_string.password.result
}

output "sp_id" {
  value = azuread_service_principal.sp.id
}

output "client_id" {
  value = azuread_application.app.application_id
}

output "client_secret" {
  value = azuread_service_principal_password.pwd.value
}