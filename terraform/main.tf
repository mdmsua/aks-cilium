module "cluster" {
  source        = "./modules/cluster"
  configuration = var.configuration
}

module "charts" {
  source = "./modules/charts"
}
