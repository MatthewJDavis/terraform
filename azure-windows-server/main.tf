resource "azurerm_resource_group" "myterraformgroup" {
    name     = "myResourceGroup"
    location = "uksouth"

    tags {
        environment = "Terraform Demo"
    }
}