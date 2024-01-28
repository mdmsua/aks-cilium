module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
  suffix  = [random_pet.main.id, "dev", var.location]
}

resource "random_pet" "main" {
  length = 1
}

resource "azurerm_resource_group" "main" {
  name     = module.naming.resource_group.name
  location = var.location
}

resource "azurerm_kubernetes_fleet_manager" "main" {
  name                = "fleet-${random_pet.main.id}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_role_assignment" "fleet_manager_rbac_cluster_admin" {
  for_each             = var.admins
  scope                = azurerm_kubernetes_fleet_manager.main.id
  principal_id         = each.value
  role_definition_name = "Azure Kubernetes Fleet Manager RBAC Cluster Admin"
}
