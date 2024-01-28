output "ca_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate
}

output "host" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.host
}

output "id" {
  value = azurerm_kubernetes_cluster.main.id
}
