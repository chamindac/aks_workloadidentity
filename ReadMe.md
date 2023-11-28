# Workload Identity Implementation for AKS
This is an example implementaion of workload identity that will help to understand the concept of using workload identity, to enable access to Azure resources such as app config service, key vault etc., for pods in AKS using workload identity.

### Setting up AKS with TF enabling workload identity
We need to set both below properties to true to enable workload identity for AKS in terraform resource `azurerm_kubernetes_cluster`.
```
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
```

To run IaC locally set the `subscriptionid` and `tenantid` in `iac\backends\dev.cfg`. Ensure you have astorage account created with the name of `stdemotfstate001` in a resource group named `rg-demo-tfstate` and it has a container `tfstate` (If required you can change the names of tf state resource group etc. and update the `dev.cfg` accordingly). Following command will setup AKS with workload identity enabled. AKS blue-green depoyment support is also added in the TF code.

```
  terraform init -backend-config='/backends/dev.cfg'
  terraform plan -var-file='env.tfvars' -out='my.tfplan'
  terraform apply my.tfplan
```