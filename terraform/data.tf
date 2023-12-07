data "azurerm_kubernetes_service_versions" "main" {
  location        = var.configuration.location
  include_preview = false
}

data "azuread_client_config" "main" {}
