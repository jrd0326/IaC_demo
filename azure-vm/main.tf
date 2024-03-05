provider "azurerm" {
    features {}
}

variable "admin_password" {
  description = "The admin password for the VM"
  type        = string
  sensitive   = true
}

data "azurerm_resource_group" "rg" {
    name     = "rg-web-services-php-01"
    #location = "South Central US"
}

data "azurerm_subnet" "subnet" {
  name                 = "snet-web-services-prod-001"
  virtual_network_name = "vnet-shared-prod-01"
  resource_group_name  = "rg-infrastructure-prod-01"
}

resource "azurerm_network_interface" "nic" {
    name                = "nic-php-fileadmin-01"
    location            = data.azurerm_resource_group.rg.location
    resource_group_name = data.azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = data.azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_linux_virtual_machine" "vm" {
    name                = "vm-php-fileadmin-01"
    resource_group_name = data.azurerm_resource_group.rg.name
    location            = data.azurerm_resource_group.rg.location
    size                = "Standard_D2s_v3"
    admin_username      = "untsystem"
    disable_password_authentication = false
    admin_password = var.admin_password
    network_interface_ids = [
        azurerm_network_interface.nic.id,
    ]

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
    }
}
