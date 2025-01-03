data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "ci_cd_key_vault" {
  name                        = "cicdkvsample"
  location                    = azurerm_resource_group.ci_cd_key_vault.location
  resource_group_name         = azurerm_resource_group.ci_cd_key_vault.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 90
  purge_protection_enabled    = false
  enable_rbac_authorization   = true

  sku_name = "standard"

  network_acls {
    bypass = "AzureServices"
    default_action = "Deny"
    ip_rules = ["5.198.70.47"]
  }
}

resource "azurerm_role_assignment" "ci_cd_key_vault" {
  scope                = azurerm_key_vault.ci_cd_key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_key" "ci_cd_key_vault_key" {
  name         = "ci-cd-key-vault-key"
  key_vault_id = azurerm_key_vault.ci_cd_key_vault.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify"]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after = "P90D"
    notify_before_expiry = "P31D"
  }
}