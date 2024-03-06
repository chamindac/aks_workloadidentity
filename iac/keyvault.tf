# This alone does not work for destroy KV. Need pipeline to set and remove agent if KV is deleted. Add pipeline IP steps to TF apply if KV need to be destroyed via TF and to ensure build agent IP removed from KV after use for deployment.
# Secrets update and delete works in second attempt as plan and apply happen in same build agent in 2 and 3 attempts.
# Get IP of build agent (Hosted agent IP is dynamic)
data "http" "mytfip" {
  url = "https://api.ipify.org" # http://ipv4.icanhazip.com
}

resource "azurerm_key_vault" "instancekeyvault" {
  name                        = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}-kv"
  location                    = azurerm_resource_group.instancerg.location
  resource_group_name         = azurerm_resource_group.instancerg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_deployment      = false
  enabled_for_disk_encryption = false
  purge_protection_enabled    = false # allow purge for drop and create in demos. else this should be set to true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["${chomp(data.http.mytfip.response_body)}/32"]
    virtual_network_subnet_ids = [
      "${azurerm_subnet.aks.id}"
    ]
  }

  # Sub Owners
  access_policy {
    tenant_id               = var.TENANTID
    object_id               = data.azuread_group.sub_owners.object_id
    key_permissions         = ["Get", "Purge", "Recover"]
    secret_permissions      = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
    certificate_permissions = ["Create", "Get", "Import", "List", "Update", "Delete", "Purge", "Recover"]
  }

  # Infra Deployment Service Principal
  access_policy {
    tenant_id               = data.azurerm_client_config.current.tenant_id
    object_id               = data.azurerm_client_config.current.object_id
    key_permissions         = ["Get", "Purge", "Recover"]
    secret_permissions      = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
    certificate_permissions = ["Create", "Get", "Import", "List", "Update", "Delete", "Purge", "Recover"]
  }

  # Containers in AKS via user assigned identity
  access_policy {
    tenant_id          = var.TENANTID
    object_id          = azurerm_user_assigned_identity.aks.principal_id # principal_id is the object id of the user assigned identity
    secret_permissions = ["Get", "List", ]
  }

  tags = merge(tomap({
    Service = "key_vault",
  }), local.tags)
}

# Secrets 
resource "azurerm_key_vault_secret" "secret" {
  for_each = {
    DemoSharedSecret1    = "Notarealsecret1"
    DemoSharedSecret2    = "Notarealsecret2"
    DemoBGSecret-1-blue  = "Notarealbgsecret1blue"
    DemoBGSecret-2-blue  = "Notarealbgsecret2blue"
    DemoBGSecret-1-green = "Notarealbgsecret1green"
    DemoBGSecret-2-green = "Notarealbgsecret2green"
  }
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.instancekeyvault.id

  depends_on = [
    azurerm_key_vault.instancekeyvault
  ]
}