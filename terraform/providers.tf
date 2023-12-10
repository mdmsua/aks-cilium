terraform {
  backend "remote" {
    organization = "Mangocado"

    workspaces {
      name = "cilium"
    }
  }
}

