# resource "azurerm_storage_account" "queue" {
#   name                     = "${var.PREFIX}${var.PROJECT}${replace(var.ENVNAME, "-", "")}queuest"
#   resource_group_name      = azurerm_resource_group.instancerg.name
#   location                 = azurerm_resource_group.instancerg.location
#   account_tier                     = "Standard"
#   account_replication_type         = "LRS"
#   account_kind                     = "StorageV2"
#   access_tier                      = "Hot"
#   allow_nested_items_to_be_public  = false
#   min_tls_version                  = "TLS1_2"
#   cross_tenant_replication_enabled = false
# }

# resource "azurerm_storage_queue" "video" {
#   name                 = "demovideoqueue"
#   storage_account_name = azurerm_storage_account.queue.name
# }

# resource "azurerm_storage_queue" "dotnet_video" {
#   name                 = "dotnetvideoqueue"
#   storage_account_name = azurerm_storage_account.queue.name
# }