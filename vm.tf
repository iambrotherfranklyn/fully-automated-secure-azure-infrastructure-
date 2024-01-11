
# Azure Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "demo-task-vm" {
  for_each = toset(var.demo_task_vm_names)
  name     = each.value
  #name                = "demotaskvm"
  #computer_name       = "demotask-vm"
  resource_group_name = azurerm_resource_group.demo-task-rg.name
  location            = azurerm_resource_group.demo-task-rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  #admin_password      = "Password1234!"
  admin_password = azurerm_key_vault_secret.demo_task_vm_secrets[each.key].value

  network_interface_ids = [
    azurerm_network_interface.demo-task-vm-nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.demo-task-user-assigned-identity.id]
  }

  depends_on = [azurerm_key_vault_secret.demo_task_vm_secrets]
}
