# Outputs the below terraform values at the end of the TF CLI run. 

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = azurerm_windows_virtual_machine.web_vm.public_ip_address
}

output "admin_username" {
  value     = azurerm_windows_virtual_machine.web_vm.admin_username
}

output "admin_password" {
  sensitive = true
  value     = azurerm_windows_virtual_machine.web_vm.admin_password
}