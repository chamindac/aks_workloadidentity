# Workload Identity Implementation for AKS Using Terraform
This is an example implementaion of workload identity that will help to understand the concept of using workload identity, to enable access to Azure resources such as app config service, key vault etc., for pods in AKS using workload identity.

### Setting up AKS with TF enabling workload identity
We need to set both below properties to true to enable workload identity for AKS in terraform resource `azurerm_kubernetes_cluster` in `iac\modules\aks\main.tf`.
```
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
```

Then we need to setup a user assigned identity (OR can use Azure AD application, but usaer assigned identity is preffred) This identity will be used later to assign permisions to other Azure resources, which should be accessed by applications deployed to AKS. The identity is created as common, so it can be used with both blue and green AKS instances. In `iac\rbac.tf`.

```
resource "azurerm_user_assigned_identity" "aks" {
  location            = azurerm_resource_group.instancerg.location
  name                = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}-aks-uai"
  resource_group_name = azurerm_resource_group.instancerg.name
}
```

In AKS module we have to define a federated identity credential for the user assigned id and for the kubernetes service account (see `Setting up application prerequisites` section below) . Defined in in `iac\modules\aks\main.tf`.

```
resource "azurerm_federated_identity_credential" "aks" {
  name                = "${var.prefix}-${var.project}-${var.environment_name}-aks-fic-${var.deployment_name}"
  resource_group_name = var.rg_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks_cluster.oidc_issuer_url
  parent_id           = var.user_assigned_identity
  subject             = "system:serviceaccount:widemo:wi-demo-sa" # system:serviceaccount:aksapplicationnamespace:workloadidentityserviceaccountname
}
```
Grant the azure resources access to user assigned identity in terraform. Here we do for key vault and app config service.

Key vault access policy. See iac\keyvault.tf .
```
# Containers in AKS via user assigned identity
  access_policy {
    tenant_id          = var.TENANTID
    object_id          = azurerm_user_assigned_identity.aks.principal_id # principal_id is the object id of the user assigned identity
    secret_permissions = ["Get", "List", ]
  }
```
App config service data reader role. See `iac\appconfig.tf`.

```
# AKS user assigned identity as a reader
resource "azurerm_role_assignment" "appconf_datareader_aks" {
  scope                = azurerm_app_configuration.appconf.id
  role_definition_name = "App Configuration Data Reader"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}
```

### How to run IaC
To run IaC locally set the `subscriptionid` and `tenantid` in `iac\backends\dev.cfg`. Ensure you have astorage account created with the name of `stdemotfstate001` in a resource group named `rg-demo-tfstate` and it has a container `tfstate` (If required you can change the names of tf state resource group etc. and update the `dev.cfg` accordingly). Following command will setup AKS with workload identity enabled. AKS blue-green depoyment support is also added in the TF code.

```
  terraform init -backend-config='/backends/dev.cfg'
  terraform plan -var-file='env.tfvars' -out='my.tfplan'
  terraform apply my.tfplan
```

### Setting up application prerequisites
Next step is to setup a service account (will be used to provide identity for the applications running in the pods)[https://azure.github.io/azure-workload-identity/docs/concepts.html#service-account]. Service account cab setup as shown below. See `aks_manifests\prerequisites\k8s.yaml`. You can use make or use `kubectl apply -f k8s.yaml`. If a pipeline such as Azure pipeline is used, then use teraform output to obtain the user assigned identity client id, and use it in pipeline to replace token `#${USER_ASSIGNED_CLIENT_ID}$`.

```
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: "${USER_ASSIGNED_CLIENT_ID}$" # user Assigned identity client ID (aks_uai_client_id output from Terraform)
    azure.workload.identity/tenant-id: "${AZURE_TENANT_ID}$"  # Azure tenant id
    # azure.workload.identity/service-account-token-expiration: "3600" # Default is 3600. Supported range is 3600-86400. Configure to avoid down time in token refresh. Setting in Pod spec takes precedence.
  name: wi-demo-sa
  namespace: widemo
  ```


### Deploying application pod referencing service account

Build the app image and push to shared acr (a shared ACR is used here. Can use a specific ACR. Make sure AKS custer kublect identity has AcrPull role. See line 191 of `iac\modules\aks\main.tf`).

```
docker build --no-cache -t demo-wi-api:dev --progress=plain -f demo.api/Dockerfile .
docker tag demo-wi-api:dev chdemosharedacr.azurecr.io/widemo/wi-api:1.0
docker login chdemosharedacr.azurecr.io -u spnappid -p spnapppwd
docker push chdemosharedacr.azurecr.io/widemo/wi-api:1.0
```

Then deploy the application including the label and annotation shown below in the deployment, pod template metadata. See `aks_manifests\wi-api\k8s.yaml`. You can use make or use `kubectl apply -f k8s.yaml`.

```
template:
    metadata:
      labels:
        app: wi-api
        service: wi-api
        azure.workload.identity/use: "true" # Required to make the contianers in the pod to use the workload identity
      # annotations:
      #   azure.workload.identity/service-account-token-expiration: "3600" # Configure to avoid down time in token refresh. Takes precedence over servie acount setting. Default 3600, acceptable range: seconds 3600 - 86400.
      #   azure.workload.identity/skip-containers: "container1:container2" # Containers o skip using workload identity. By default all containers in pod will use workload identity when pod is labeled with azure.workload.identity/use: true 
      #   azure.workload.identity/inject-proxy-sidecar: "true" # Default true. The proxy sidecar is used to intercept token requests to IMDS (Azure Instance Metadata Service) and acquire an AAD token on behalf of the user with federated identity credential.
      #   azure.workload.identity/proxy-sidecar-port: "8000" # Port of the proxy sidecar. Default 8000
```

Since our demo api only accessible via internal ingress url within the vnet (which we can expose publicly with public IP if required, But here the intention is for the API to be used with web apps in same vnet so no need of exposing the api with public IP of ingress controlller app gateway), we can use port forwarding to access swagger ui of the API. Then we can test app configuration and keyvault secret reading works as expected in the API.

```
kubectl port-forward service/wi-api-clusterip 8085:8091 -n widemo
```

![image](https://github.com/chamindac/aks_workloadidentity/assets/20109548/599d9d1c-f078-4f1a-a588-c07417fd757f)
