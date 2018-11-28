output "PublicIP" {
  value = "${azurerm_public_ip.myterraformpublicip.ip_address}"
}
output "PublicDNS" {
  value = "${azurerm_public_ip.myterraformpublicip.domain_name_label}"
}
