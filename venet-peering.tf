# Peering from Firewall VNet to VM VNet
resource "azurerm_virtual_network_peering" "demo-task-firewall-to-vm" {
  name                         = "peer-from-firewall-to-vm"
  resource_group_name          = azurerm_resource_group.demo-task-rg.name
  virtual_network_name         = azurerm_virtual_network.demo-task-firewall-vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.demo-task-vm-vnet.id
  allow_virtual_network_access = true
  depends_on                   = [azurerm_virtual_network.demo-task-firewall-vnet, azurerm_virtual_network.demo-task-vm-vnet]

}

# Peering from VM VNet to Firewall VNet
resource "azurerm_virtual_network_peering" "demo-task-vm-to-firwall" {
  name                         = "peer-from-vm-to-firewall"
  resource_group_name          = azurerm_resource_group.demo-task-rg.name
  virtual_network_name         = azurerm_virtual_network.demo-task-vm-vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.demo-task-firewall-vnet.id
  allow_virtual_network_access = true
  depends_on                   = [azurerm_virtual_network.demo-task-vm-vnet, azurerm_virtual_network.demo-task-firewall-vnet]
}








