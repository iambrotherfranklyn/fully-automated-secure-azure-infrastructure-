
resource "azurerm_mysql_flexible_server" "demo-task-mysql-flexible-server" {
  for_each = toset(var.mysql_flexible_server_name)
  name     = each.value
  #name                = var.mysql_flexible_server_name
  resource_group_name = azurerm_resource_group.demo-task-rg.name
  location            = azurerm_resource_group.demo-task-rg.location
  administrator_login = var.db_administrator_login
  #administrator_password = var.db_administrator_password
  administrator_password = azurerm_key_vault_secret.demo_task_db_secrets[each.key].value
  backup_retention_days  = 7
  zone                   = 1
  sku_name               = "GP_Standard_D2ds_v4"
  #delegated_subnet_id    = azurerm_subnet.demo-task-db-subnet.id
  depends_on = [azurerm_resource_group.demo-task-rg]
}


resource "azurerm_mysql_flexible_database" "demo-task-database" {
  for_each = azurerm_mysql_flexible_server.demo-task-mysql-flexible-server
  name     = "database-for-${each.key}"
  #name                = var.mysql_database_name
  resource_group_name = azurerm_resource_group.demo-task-rg.name
  server_name         = each.value.name
  #server_name         = azurerm_mysql_flexible_server.demo-task-mysql-flexible-server.name
  charset   = "utf8"
  collation = "utf8_unicode_ci"

  #lifecycle {
  # prevent_destroy = true
  # }
  depends_on = [azurerm_mysql_flexible_server.demo-task-mysql-flexible-server]
}
