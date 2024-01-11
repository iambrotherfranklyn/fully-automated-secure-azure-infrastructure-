resource "azurerm_resource_group" "demo-task-rg" {
  name     = var.resource_group_name
  location = var.location
}