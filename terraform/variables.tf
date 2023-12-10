variable "configuration" {
  type = object({
    location = string
    virtual_network = object({
      address_space = string
    })
    cluster = object({
      pod_cidr     = string
      service_cidr = string
      default_node_pool = optional(object({
        vm_size   = optional(string, "Standard_D2pds_v5")
        max_count = optional(number, 50)
        max_surge = optional(string, "100%")
      }), {})
      node_pools = map(object({
        vm_size         = optional(string, "Standard_D2pds_v5")
        max_count       = optional(number, 50)
        os_disk_size_gb = optional(number, 32)
        os_disk_type    = optional(string, "Ephemeral")
        os_sku          = optional(string, "AzureLinux")
        max_surge       = optional(string, "50%")
      }))
      admins = optional(set(string), [])
    })
  })
  default = {
    location = "westeurope"
    virtual_network = {
      address_space = "192.168.255.0/24"
    }
    cluster = {
      pod_cidr     = "172.16.0.0/16"
      service_cidr = "172.17.0.0/16"
      node_pools = {
        main = {}
      }
      admins = [
        "6b1aa092-b266-49f3-be05-341fff39cd59"
      ]
    }
  }
}
