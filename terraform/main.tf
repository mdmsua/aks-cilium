module "fleet" {
  source   = "./modules/fleet"
  location = var.location
  admins   = var.admins
}

module "cluster" {
  for_each      = var.configuration
  source        = "./modules/cluster"
  configuration = merge(each.value, { name : each.key })
}

resource "terraform_data" "fleet_member" {
  for_each = var.configuration
  provisioner "local-exec" {
    command = "az fleet member create --resource-group ${module.fleet.resource_group_name} --fleet-name ${module.fleet.name} --name ${each.key} --member-cluster-id ${module.cluster[each.key].id}"
  }
}
# module "charts" {
#   source                 = "./modules/charts"
#   cluster_ca_certificate = module.cluster.ca_certificate
#   cluster_host           = module.cluster.host
# }
