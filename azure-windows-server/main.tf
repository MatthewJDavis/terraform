provider "azurerm" {
    subscription_id = "${var.subscription_id}"
    tenant_id = "${var.tenant_id}"
    client_id = "${var.client_id}"
    client_secret = "${var.client_secret}"
}
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "myResourceGroup"
    location = "uksouth"

    tags {
        environment = "Terraform Demo"
    }
}