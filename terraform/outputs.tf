output "ca_certificate" {
  value     = azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.main.kube_config.0.host
  sensitive = true
}
