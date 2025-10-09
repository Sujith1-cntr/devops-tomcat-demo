output "app_name"     { value = azurerm_linux_web_app.app.name }
output "resource_grp" { value = azurerm_resource_group.rg.name }
output "web_url"      { value = "https://${azurerm_linux_web_app.app.default_hostname}" }
