module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
  suffix  = [random_pet.main.id, var.configuration.location]
}

resource "azuread_group" "main" {
  display_name               = "${random_pet.main.id}-cluster-admins"
  assignable_to_role         = false
  auto_subscribe_new_members = false
  external_senders_allowed   = false
  mail_enabled               = false
  prevent_duplicate_names    = true
  security_enabled           = true
  owners                     = [data.azuread_client_config.main.object_id]
  members                    = setunion([data.azuread_client_config.main.object_id], var.configuration.cluster.admins)
}

resource "random_pet" "main" {}

resource "azurerm_resource_group" "main" {
  name     = module.naming.resource_group.name
  location = var.configuration.location
}

resource "azurerm_virtual_network" "main" {
  name                = module.naming.virtual_network.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = [var.configuration.virtual_network.address_space]
}

resource "azurerm_subnet" "main" {
  name                 = module.naming.subnet.name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = azurerm_virtual_network.main.address_space
}

resource "azurerm_public_ip_prefix" "main" {
  name                = module.naming.public_ip_prefix.name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  ip_version          = "IPv4"
  prefix_length       = 28
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "main" {
  name                    = module.naming.nat_gateway.name
  resource_group_name     = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location
  idle_timeout_in_minutes = 4
  sku_name                = "Standard"
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "main" {
  nat_gateway_id      = azurerm_nat_gateway.main.id
  public_ip_prefix_id = azurerm_public_ip_prefix.main.id
}

resource "azurerm_subnet_nat_gateway_association" "main" {
  nat_gateway_id = azurerm_nat_gateway.main.id
  subnet_id      = azurerm_subnet.main.id
}

resource "azurerm_user_assigned_identity" "cluster" {
  name                = "${module.naming.user_assigned_identity.name}-cluster"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_user_assigned_identity" "kubelet" {
  name                = "${module.naming.user_assigned_identity.name}-kubelet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_role_assignment" "cluster_managed_identity_operator_kubelet" {
  principal_id         = azurerm_user_assigned_identity.cluster.principal_id
  role_definition_name = "Managed Identity Operator"
  scope                = azurerm_user_assigned_identity.kubelet.id
}

resource "azurerm_kubernetes_cluster" "main" {
  name                              = module.naming.kubernetes_cluster.name
  resource_group_name               = azurerm_resource_group.main.name
  location                          = azurerm_resource_group.main.location
  automatic_channel_upgrade         = "patch"
  dns_prefix                        = random_pet.main.id
  image_cleaner_enabled             = true
  image_cleaner_interval_hours      = 24
  kubernetes_version                = data.azurerm_kubernetes_service_versions.main.latest_version
  local_account_disabled            = true
  oidc_issuer_enabled               = true
  role_based_access_control_enabled = true
  workload_identity_enabled         = true

  http_application_routing_enabled    = false
  run_command_enabled                 = false
  azure_policy_enabled                = false
  private_cluster_enabled             = false
  open_service_mesh_enabled           = false
  private_cluster_public_fqdn_enabled = false

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    ebpf_data_plane     = "cilium"
    pod_cidr            = var.configuration.cluster.pod_cidr
    service_cidr        = var.configuration.cluster.service_cidr
    dns_service_ip      = cidrhost(var.configuration.cluster.service_cidr, 10)
    outbound_type       = "userAssignedNATGateway"

    nat_gateway_profile {
      idle_timeout_in_minutes = 4
    }
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.kubelet.client_id
    object_id                 = azurerm_user_assigned_identity.kubelet.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.kubelet.id
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.cluster.id
    ]
  }

  default_node_pool {
    name                         = "default"
    enable_auto_scaling          = true
    min_count                    = 3
    max_count                    = var.configuration.cluster.default_node_pool.max_count
    max_pods                     = 250
    only_critical_addons_enabled = true
    os_disk_size_gb              = 32
    os_disk_type                 = "Ephemeral"
    os_sku                       = "AzureLinux"
    temporary_name_for_rotation  = "temp"
    vm_size                      = var.configuration.cluster.default_node_pool.vm_size
    vnet_subnet_id               = azurerm_subnet.main.id
    zones                        = local.zones

    upgrade_settings {
      max_surge = var.configuration.cluster.default_node_pool.max_surge
    }
  }

  azure_active_directory_role_based_access_control {
    admin_group_object_ids = [azuread_group.main.id]
    managed                = true
    azure_rbac_enabled     = false
  }

  depends_on = [
    azurerm_subnet_nat_gateway_association.main,
    azurerm_nat_gateway_public_ip_prefix_association.main
  ]
}

resource "azurerm_kubernetes_cluster_node_pool" "main" {
  for_each              = var.configuration.cluster.node_pools
  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = each.value.max_count
  max_pods              = 250
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_disk_type          = each.value.os_disk_type
  os_sku                = each.value.os_sku
  mode                  = "User"
  vm_size               = each.value.vm_size
  vnet_subnet_id        = azurerm_subnet.main.id
  zones                 = local.zones

  upgrade_settings {
    max_surge = each.value.max_surge
  }
}

resource "azurerm_role_assignment" "cluster_admin_user_role" {
  for_each             = var.configuration.cluster.admins
  scope                = azurerm_kubernetes_cluster.main.id
  principal_id         = each.value
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
}
