terraform {
  backend "remote" {
    organization = "Exatron"

    workspaces {
      name = "cilium"
    }
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
  tenant_id       = var.spec.tenant_id
  subscription_id = var.spec.subscription_id
}

# provider "helm" {
#   kubernetes {
#     cluster_ca_certificate = base64decode(module.cluster.ca_certificate)
#     host                   = module.cluster.host

#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       command     = "kubelogin"
#       args = [
#         "get-token",
#         "--server-id",
#         "6dae42f8-4368-4678-94ff-3960e28e3630",
#         "--login",
#         "azurecli"
#       ]
#     }
#   }
# }
