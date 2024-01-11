resource "azurerm_user_assigned_identity" "demo-task-user-assigned-identity" {
  resource_group_name = azurerm_resource_group.demo-task-rg.name
  location            = azurerm_resource_group.demo-task-rg.location

  name = "demo-task-identity"
}


resource "azurerm_role_assignment" "demo-task-kv-role" {
  scope                = azurerm_key_vault.demo-task-key-vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_user_assigned_identity.demo-task-user-assigned-identity.principal_id
  depends_on           = [azurerm_user_assigned_identity.demo-task-user-assigned-identity]
}

resource "azurerm_role_assignment" "demo-task-mysql-role" {
  for_each = azurerm_mysql_flexible_server.demo-task-mysql-flexible-server

  scope = each.value.id

  #scope                = azurerm_mysql_flexible_server.demo-task-mysql-flexible-server.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.demo-task-user-assigned-identity.principal_id
  depends_on           = [azurerm_user_assigned_identity.demo-task-user-assigned-identity]
}