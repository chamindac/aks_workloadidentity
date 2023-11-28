output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}

output "aks_oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.aks_cluster.oidc_issuer_url
}