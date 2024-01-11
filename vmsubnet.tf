resource "azurerm_virtual_network" "demo-task-vm-vnet" {
  name                = var.vm_vnet
  location            = azurerm_resource_group.demo-task-rg.location
  resource_group_name = azurerm_resource_group.demo-task-rg.name
  address_space       = var.vm_vnet_address_space
  depends_on          = [azurerm_resource_group.demo-task-rg]
}


resource "azurerm_subnet" "demo-task-vm-subnet" {
  name                 = "vm_subnet"
  resource_group_name  = azurerm_resource_group.demo-task-rg.name
  virtual_network_name = azurerm_virtual_network.demo-task-vm-vnet.name
  address_prefixes     = ["10.50.0.0/24"]
  depends_on           = [azurerm_virtual_network.demo-task-vm-vnet]
}
resource "azurerm_network_interface" "demo-task-vm-nic" {
  name                = "demo_task_vm_nic"
  location            = azurerm_resource_group.demo-task-rg.location
  resource_group_name = azurerm_resource_group.demo-task-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.demo-task-vm-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.50.0.4"
  }
}
resource "azurerm_network_security_group" "demo-task-vm-security-group" {
  name                = "demo_task_vm_security_group"
  location            = azurerm_resource_group.demo-task-rg.location
  resource_group_name = azurerm_resource_group.demo-task-rg.name
  depends_on          = [azurerm_resource_group.demo-task-rg]
}

resource "azurerm_subnet_network_security_group_association" "demo-task-vm-network_security_group_association" {
  subnet_id                 = azurerm_subnet.demo-task-vm-subnet.id
  network_security_group_id = azurerm_network_security_group.demo-task-vm-security-group.id
  depends_on                = [azurerm_network_security_group.demo-task-vm-security-group]
}

/*resource "azurerm_private_endpoint" "vm-endpoint" {
  name                = "demotask-vm-private-endpoint"
  location            = azurerm_resource_group.demo-task-rg.location
  resource_group_name = azurerm_resource_group.demo-task-rg.name
  subnet_id           = azurerm_subnet.vm-subnet.id

  private_service_connection {
    name                           = "demo-task-vm-private-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_windows_virtual_machine.demo-task-vm.id
    subresource_names              = ["mysqlServer"]
    
  }

  custom_dns_configs {
    fqdn    = "mysqlserver.private"
    ip_addresses = var.allowed_public_ip
  }
  depends_on = [ azurerm_subnet.vm-subnet ]
}
*/

/*
resource "azurerm_network_security_rule" "demo-task-vm-securty-rule" {
  name                        = "AllowMyIP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = var.firewall_public_ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.demo-task-rg.name
  network_security_group_name = azurerm_network_security_group.demo-task-vm-security-group.name
  depends_on                  = [azurerm_network_security_group.demo-task-vm-security-group]
}
*/

/*
# Block outbound HTTPS (port 443)
resource "azurerm_network_security_rule" "block-outbound-https" {
  name                        = "block_outbound_https"
  priority                    = 310
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         =azurerm_resource_group.demo-task-rg.name
  network_security_group_name = azurerm_network_security_group.demo-task-vm-security-group.name
}
*/