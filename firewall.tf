
resource "azurerm_virtual_network" "demo-task-firewall-vnet" {
  name                = "demo_tasks_firewall_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.demo-task-rg.location
  resource_group_name = azurerm_resource_group.demo-task-rg.name
  depends_on          = [azurerm_resource_group.demo-task-rg]
}

resource "azurerm_subnet" "firewall-subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.demo-task-rg.name
  virtual_network_name = azurerm_virtual_network.demo-task-firewall-vnet.name
  address_prefixes     = ["10.0.1.0/26"]
  depends_on           = [azurerm_virtual_network.demo-task-firewall-vnet]
}

resource "azurerm_public_ip" "firewall-ip" {
  name                = "demo-task-firewall-Public-ip"
  location            = azurerm_resource_group.demo-task-rg.location
  resource_group_name = azurerm_resource_group.demo-task-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on          = [azurerm_resource_group.demo-task-rg]
}

resource "azurerm_firewall" "demo-task-firewall" {
  name                = "demo_task_firewall"
  location            = azurerm_resource_group.demo-task-rg.location
  resource_group_name = azurerm_resource_group.demo-task-rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall-subnet.id
    public_ip_address_id = azurerm_public_ip.firewall-ip.id
  }
  depends_on = [azurerm_subnet.firewall-subnet]
}

resource "azurerm_firewall_nat_rule_collection" "demo-task-firewall-nat-rule" {
  name                = "demo_task_firewall_nat_rules"
  azure_firewall_name = azurerm_firewall.demo-task-firewall.name
  resource_group_name = azurerm_resource_group.demo-task-rg.name
  priority            = 100
  action              = "Dnat"

  rule {
    name = "demo_task_rule"

    source_addresses = [
      "92.7.185.142", #my local machine address
    ]

    destination_ports = [
      "3389",
    ]

    destination_addresses = [
      azurerm_public_ip.firewall-ip.ip_address
    ]

    translated_port = 3389

    translated_address = "10.50.0.4" #private ip ofr the vm
    protocols = [
      "TCP",

    ]
  }
}