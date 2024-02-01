variable "configuration" {
  type = object({
    project  = string
    location = string
    virtual_network = object({
      address_space = string
    })
    cluster = object({
      pod_cidr           = string
      service_cidr       = string
      kubernetes_version = string
      default_node_pool = optional(object({
        vm_size   = optional(string, "Standard_D2pds_v5")
        max_surge = optional(string, "100%")
      }), {})
      node_pools = optional(list(object({
        name            = string
        max_count       = optional(number, 3)
        vm_size         = optional(string, "Standard_D2pds_v5")
        os_disk_size_gb = optional(number, 32)
        os_disk_type    = optional(string, "Ephemeral")
        os_sku          = optional(string, "AzureLinux")
        max_surge       = optional(string, "100%")
      })), [])
      admins = optional(set(string), [])
    })
  })
}
