variable "spec" {
  type = object({
    project         = string
    tenant_id       = string
    subscription_id = string
    location        = string
    zones           = set(string)
    virtual_network = object({
      address_space = list(string)
    })
    cluster = object({
      version       = string
      pod_cidrs     = list(string)
      service_cidrs = list(string)
      default_node_pool = object({
        min_count       = number
        max_count       = number
        max_pods        = number
        vm_size         = string
        os_disk_size_gb = number
        os_disk_type    = string
        os_sku          = string
        max_surge       = string
      })
      node_pools = set(object({
        name            = string
        mode            = string
        min_count       = number
        max_count       = number
        max_pods        = number
        vm_size         = string
        os_disk_size_gb = number
        os_disk_type    = string
        os_sku          = string
        max_surge       = string
      }))
      admins = set(string)
    })
  })
}
