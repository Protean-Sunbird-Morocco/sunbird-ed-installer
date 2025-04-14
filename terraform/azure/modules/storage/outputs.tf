output "azurerm_storage_account_name" {
  value = azurerm_storage_account.storage_account.name
}

output "azurerm_storage_account_key" {
  value = azurerm_storage_account.storage_account.primary_access_key
  sensitive = true
}

output "azurerm_storage_container_private" {
  value = azurerm_storage_container.storage_container_private.name
}

output "azurerm_storage_container_public" {
  value = azurerm_storage_container.storage_container_public.name
}
output "azurerm_reports_container_private" {
  value = azurerm_storage_container.reports_container_private.name
}
output "azurerm_backups_container_private" {
  value = azurerm_storage_container.backups_container_private.name
}
output "azurerm_flink_state_container_private" {
  value = azurerm_storage_container.flink_state_container_private.name
}
output "azurerm_dial_state_container_public" {
  value = azurerm_storage_container.dial_state_container_public.name
}
output "azurerm_telemetry_container_private" {
  value = azurerm_storage_container.telemetry_container_private.name
}
output azurerm_terms_and_conditions_container {
  value = azurerm_storage_container.terms_and_conditions_container.name
}

output azurerm_public_state_container {
  value = azurerm_storage_container.public_state_container.name
}

output azurerm_sourcing_state_container {
  value = azurerm_storage_container.sourcing_state_container.name
}