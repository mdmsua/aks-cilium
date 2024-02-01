locals {
  project = coalesce(var.configuration.project, random_pet.main.id)
  node_pools = {
    for x in setproduct(var.configuration.cluster.node_pools, local.zones) : "${x[0].name}${x[1]}" => merge(x[0], {
      zone                         = x[1],
      subnet_id                    = azurerm_subnet.main[x[1]].id,
      proximity_placement_group_id = azurerm_proximity_placement_group.main[x[1]].id
  }) }
  zones = toset(["1", "2", "3"])
}
