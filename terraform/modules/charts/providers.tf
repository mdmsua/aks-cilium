terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.0"
    }
  }
}

provider "helm" {
  kubernetes {
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    host                   = var.cluster_host

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args = [
        "get-token",
        "--server-id",
        "6dae42f8-4368-4678-94ff-3960e28e3630",
        "--login",
        "azurecli"
      ]
    }
  }
}
