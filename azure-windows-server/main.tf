# https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html
resource "azurerm_resource_group" "main" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"

  tags = {
    environment = "${var.tagValue}"
  }
}

resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "${var.computer_name}-public-ip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  allocation_method   = "Dynamic"

  tags = {
    environment = "${var.tagValue}"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "${var.computer_name}-nsg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WinRM"
    priority                   = 1011
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "${var.tagValue}"
  }
}

resource "azurerm_network_interface" "myterraformnic" {
  name                      = "${var.computer_name}-nic"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

  ip_configuration {
    name                          = "${var.computer_name}-nic-config"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
  }

  tags = {
    environment = "${var.tagValue}"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_virtual_machine" "myterraformvm" {
  name                          = "${var.computer_name}"
  location                      = "${var.location}"
  resource_group_name           = "${azurerm_resource_group.main.name}"
  network_interface_ids         = ["${azurerm_network_interface.myterraformnic.id}"]
  vm_size                       = "Standard_A1_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core-smalldisk"
    version   = "latest"
  }

  storage_os_disk {
    name              = "server-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.computer_name}"
    admin_username = "${var.user_name}"
    admin_password = "${var.password}"
  }

  os_profile_windows_config {
  }

}
