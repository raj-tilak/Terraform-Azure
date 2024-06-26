#Ref : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "firstRG" {
  name     = "RG001"
  location = "West Europe"
}

resource "azurerm_virtual_network" "virtualnetwork001" {
  name                = "VNET001"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.firstRG.location
  resource_group_name = azurerm_resource_group.firstRG.name
}

resource "azurerm_subnet" "subnet001" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.firstRG.name
  virtual_network_name = azurerm_virtual_network.firstRG.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "netinterface01" {
  name                = "nic001"
  location            = azurerm_resource_group.firstRG.location
  resource_group_name = azurerm_resource_group.firstRG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "VM001" {
  name                = "VM001"
  resource_group_name = azurerm_resource_group.firstRG.name
  location            = azurerm_resource_group.firstRG.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
