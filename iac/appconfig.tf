data "azurerm_client_config" "current" {}

resource "azurerm_app_configuration" "appconf" {
  name                = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}-appconfig-ac"
  resource_group_name = azurerm_resource_group.instancerg.name
  location            = azurerm_resource_group.instancerg.location
  sku                 = "standard"

  tags = merge(tomap({
    Service = "app_config"
  }), local.tags)
}

resource "azurerm_role_assignment" "appconf_dataowner_iacspn" {
  scope                = azurerm_app_configuration.appconf.id
  role_definition_name = "App Configuration Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "appconf_dataowner_subowners" {
  scope                = azurerm_app_configuration.appconf.id
  role_definition_name = "App Configuration Data Owner"
  principal_id         = data.azuread_group.sub_owners.object_id
}

# AKS user assigned identity as a reader
resource "azurerm_role_assignment" "appconf_datareader_aks" {
  scope                = azurerm_app_configuration.appconf.id
  role_definition_name = "App Configuration Data Reader"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

resource "azurerm_app_configuration_key" "config_kv" {
  for_each = {
    "DemoSharedConfig1" = "SharedConfig1"
    "DemoSharedConfig2" = "SharedConfig2"
  }
  configuration_store_id = azurerm_app_configuration.appconf.id
  key                    = each.key
  type                   = "kv" # key value
  label                  = azurerm_resource_group.instancerg.name
  value                  = each.value
  depends_on = [
    azurerm_role_assignment.appconf_dataowner_iacspn,
    azurerm_role_assignment.appconf_dataowner_subowners
  ]
}

resource "azurerm_app_configuration_key" "config_kv_blue" {
  for_each = {
    "DemoConfig1" = "DemoConfig1_Blue"
    "DemoConfig2" = "DemoConfig2_Blue"
  }
  configuration_store_id = azurerm_app_configuration.appconf.id
  key                    = each.key
  type                   = "kv" # key value
  label                  = "${azurerm_resource_group.instancerg.name}-${local.deployment_name_blue}"
  value                  = each.value
  depends_on = [
    azurerm_role_assignment.appconf_dataowner_iacspn,
    azurerm_role_assignment.appconf_dataowner_subowners
  ]
}

resource "azurerm_app_configuration_key" "config_kv_green" {
  for_each = {
    "DemoConfig1" = "DemoConfig1_Green"
    "DemoConfig2" = "DemoConfig2_Green"
  }
  configuration_store_id = azurerm_app_configuration.appconf.id
  key                    = each.key
  type                   = "kv" # key value
  label                  = "${azurerm_resource_group.instancerg.name}-${local.deployment_name_green}"
  value                  = each.value
  depends_on = [
    azurerm_role_assignment.appconf_dataowner_iacspn,
    azurerm_role_assignment.appconf_dataowner_subowners
  ]
}

resource "azurerm_app_configuration_key" "config_vault" {
  for_each = {
    "DemoSharedSecret1" = azurerm_key_vault_secret.secret["DemoSharedSecret1"].versionless_id
    "DemoSharedSecret2" = azurerm_key_vault_secret.secret["DemoSharedSecret2"].versionless_id
  }
  configuration_store_id = azurerm_app_configuration.appconf.id
  key                    = each.key
  type                   = "vault" # keyvault reference
  label                  = azurerm_resource_group.instancerg.name
  vault_key_reference    = each.value
  depends_on = [
    azurerm_role_assignment.appconf_dataowner_iacspn,
    azurerm_role_assignment.appconf_dataowner_subowners
  ]
}

resource "azurerm_app_configuration_key" "config_vault_blue" {
  for_each = {
    "DemoBGSecret1" = azurerm_key_vault_secret.secret["DemoBGSecret-1-blue"].versionless_id
    "DemoBGSecret2" = azurerm_key_vault_secret.secret["DemoBGSecret-2-blue"].versionless_id
  }
  configuration_store_id = azurerm_app_configuration.appconf.id
  key                    = each.key
  type                   = "vault" # keyvault reference
  label                  = "${azurerm_resource_group.instancerg.name}-${local.deployment_name_blue}"
  vault_key_reference    = each.value
  depends_on = [
    azurerm_role_assignment.appconf_dataowner_iacspn,
    azurerm_role_assignment.appconf_dataowner_subowners
  ]
}

resource "azurerm_app_configuration_key" "config_vault_green" {
  for_each = {
    "DemoBGSecret1" = azurerm_key_vault_secret.secret["DemoBGSecret-1-green"].versionless_id
    "DemoBGSecret2" = azurerm_key_vault_secret.secret["DemoBGSecret-2-green"].versionless_id
  }
  configuration_store_id = azurerm_app_configuration.appconf.id
  key                    = each.key
  type                   = "vault" # keyvault reference
  label                  = "${azurerm_resource_group.instancerg.name}-${local.deployment_name_green}"
  vault_key_reference    = each.value
  depends_on = [
    azurerm_role_assignment.appconf_dataowner_iacspn,
    azurerm_role_assignment.appconf_dataowner_subowners
  ]
}