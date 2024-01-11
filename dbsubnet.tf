

resource "azurerm_subnet" "demo-task-db-subnet" {
  name                 = "demo_task_db_subnet"
  resource_group_name  = azurerm_resource_group.demo-task-rg.name
  virtual_network_name = azurerm_virtual_network.demo-task-vm-vnet.name
  address_prefixes     = ["10.50.20.0/24"]
  #service_endpoints    = ["Microsoft.Sql"]
  depends_on = [azurerm_virtual_network.demo-task-vm-vnet]
  #delegation {
  # name = "delegation"

  # service_delegation {
  #  name    = "Microsoft.DBforMySQL/flexibleServers"
  # actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
  # }
  #}
}



resource "azurerm_network_security_group" "demo-task-db-security-group" {
  name                = "demo_task_db_security_group"
  location            = azurerm_resource_group.demo-task-rg.location
  resource_group_name = azurerm_resource_group.demo-task-rg.name
  depends_on          = [azurerm_resource_group.demo-task-rg]
}

resource "azurerm_subnet_network_security_group_association" "demo-task-network-security-group-association" {
  subnet_id                 = azurerm_subnet.demo-task-vm-subnet.id
  network_security_group_id = azurerm_network_security_group.demo-task-vm-security-group.id
  depends_on                = [azurerm_network_security_group.demo-task-vm-security-group]
}


/*
resource "azurerm_network_security_rule" "demo-task-db-securty-rule" {
  name                        = "AllowMyIP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = var.db_source_address
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.demo-task-rg.name
  network_security_group_name = azurerm_network_security_group.demo-task-vm-security-group.name
  depends_on                  = [azurerm_network_security_group.demo-task-vm-security-group]
}
*/


resource "azurerm_private_endpoint" "demo-task-db-endpoint" {
  for_each = azurerm_mysql_flexible_server.demo-task-mysql-flexible-server
  name     = "demo_task_db_endpoint_${each.key}"
  # name                = "demo_task_db_endpoint"
  location            = azurerm_resource_group.demo-task-rg.location
  resource_group_name = azurerm_resource_group.demo-task-rg.name
  subnet_id           = azurerm_subnet.demo-task-db-subnet.id
  private_service_connection {
    name                           = "demo_task_privateserviceconnection_${each.key}"
    private_connection_resource_id = each.value.id
    #name                           = "demo-task-privateserviceconnection"
    #private_connection_resource_id = azurerm_mysql_flexible_server.demo-task-mysql-flexible-server.id
    subresource_names    = ["mysqlServer"]
    is_manual_connection = false
  }
  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.mysql.name
    private_dns_zone_ids = [azurerm_private_dns_zone.mysql.id]
  }

}

resource "azurerm_private_dns_zone" "mysql" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.demo-task-rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql-link" {
  name                  = "mysql-dns-zone-link"
  resource_group_name   = azurerm_resource_group.demo-task-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.demo-task-vm-vnet.id
}













