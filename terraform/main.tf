module "cluster" {
  source        = "./modules/cluster"
  configuration = var.configuration
}

module "charts" {
  source                 = "./modules/charts"
  cluster_ca_certificate = module.cluster.ca_certificate
  cluster_host           = module.cluster.host
}
