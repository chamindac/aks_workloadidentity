# refer to sub_owners ad group to assign as aks admins 
data "azuread_group" "sub_owners" {
  display_name     = "sub_owners"
  security_enabled = true
}

resource "azurerm_user_assigned_identity" "aks" {
  location            = azurerm_resource_group.instancerg.location
  name                = "${var.PREFIX}-${var.PROJECT}-${var.ENVNAME}-aks-uai"
  resource_group_name = azurerm_resource_group.instancerg.name
}