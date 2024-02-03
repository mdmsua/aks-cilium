locals {
  node_pools = {
    for x in setproduct(var.spec.cluster.node_pools, var.spec.zones) : "${x.0.name}${x.1}" => merge(x.0, {
      zone      = x.1,
      subnet_id = azurerm_subnet.main[x.1].id,
  }) }
  ipv6_mask_bits = 64 - tonumber(split("/", var.spec.virtual_network.address_space.1).1)
}
