# Workload Identity Implementation for AKS
This is an example implementaion of workload identity that will help to understand the concept of using workload identity, to enable access to Azure resources such as app config service, key vault etc., for pods in AKS using workload identity.

### Setting up AKS with TF enabling workload identity
We need to set both below properties to true to enable workload identity in AKS in terraform resource `azurerm_kubernetes_cluster`
```
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
```