

data "azurerm_client_config" "demo-task-tenant-config" {}
resource "azurerm_key_vault" "demo-task-key-vault" {
  name                        = "demotaskkeyvault99003945"
  location                    = azurerm_resource_group.demo-task-rg.location
  resource_group_name         = azurerm_resource_group.demo-task-rg.name
  sku_name                    = "standard"
  tenant_id                   = data.azurerm_client_config.demo-task-tenant-config.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enabled_for_disk_encryption = true

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    #bypass                     = "none"
    ip_rules                   = ["92.7.185.142"]
    virtual_network_subnet_ids = []
  }
  timeouts {
    create = "30m"
    read   = "30m"
  }
}

/*
resource "azurerm_key_vault_secret" "demo_task_vm_secrets" {
  name         = "db-secret"
  value        = var.db_administrator_password
  key_vault_id = azurerm_key_vault.demo-task-key-vault.id
}
*/


resource "azurerm_key_vault_access_policy" "demo-task-db-kv_access_policy" {
  key_vault_id = azurerm_key_vault.demo-task-key-vault.id

  tenant_id = data.azurerm_client_config.demo-task-tenant-config.tenant_id
  object_id = azurerm_user_assigned_identity.demo-task-user-assigned-identity.principal_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
  ]
  depends_on = [azurerm_key_vault.demo-task-key-vault]
}

#mine
resource "azurerm_key_vault_access_policy" "demo-task-db-kv_access_policy_franklyn" {
  key_vault_id = azurerm_key_vault.demo-task-key-vault.id

  tenant_id = data.azurerm_client_config.demo-task-tenant-config.tenant_id
  object_id = "4eb31a59-f884-4a52-a7fe-3cd29615581b"

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
  ]
  depends_on = [azurerm_key_vault.demo-task-key-vault]
}


#Password generator for Vms
data "external" "demo_task_vm_passwords" {
  program = ["powershell", "${path.module}/password-gen.ps1", join(",", var.demo_task_vm_names)]
}

resource "azurerm_key_vault_secret" "demo_task_vm_secrets" {
  for_each = data.external.demo_task_vm_passwords.result

  name         = "password-${each.key}"
  value        = each.value
  key_vault_id = azurerm_key_vault.demo-task-key-vault.id
  depends_on   = [azurerm_key_vault_access_policy.demo-task-db-kv_access_policy]
}



#Password generator for database servers
data "external" "demo_task_db_passwords" {
  program = ["powershell", "${path.module}/password-gen.ps1", join(",", var.mysql_flexible_server_name)]
}

resource "azurerm_key_vault_secret" "demo_task_db_secrets" {
  for_each = data.external.demo_task_db_passwords.result

  name         = "password-${each.key}"
  value        = each.value
  key_vault_id = azurerm_key_vault.demo-task-key-vault.id
  depends_on   = [azurerm_key_vault_access_policy.demo-task-db-kv_access_policy]
}

resource "azurerm_private_endpoint" "demo-task-kv-private-endpoint" {
  name                = "demo_task_kv_endpoint"
  location            = azurerm_resource_group.demo-task-rg.location
  resource_group_name = azurerm_resource_group.demo-task-rg.name
  subnet_id           = azurerm_subnet.demo-task-kv-subnet.id

  private_service_connection {
    name                           = "kv-private-connection"
    private_connection_resource_id = azurerm_key_vault.demo-task-key-vault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.kv.name
    private_dns_zone_ids = [azurerm_private_dns_zone.kv.id]
  }

}

resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.demo-task-rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv-link" {
  name                  = "kv-dns-zone-link"
  resource_group_name   = azurerm_resource_group.demo-task-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = azurerm_virtual_network.demo-task-vm-vnet.id
}



resource "azurerm_subnet" "demo-task-kv-subnet" {
  name                 = "demo_task_kv_subnet"
  resource_group_name  = azurerm_resource_group.demo-task-rg.name
  virtual_network_name = azurerm_virtual_network.demo-task-vm-vnet.name
  address_prefixes     = ["10.50.30.0/24"]
  depends_on           = [azurerm_virtual_network.demo-task-vm-vnet]
  #
}