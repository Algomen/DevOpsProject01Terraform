# Choose Microsoft Azure Provider
provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "main" {
  name = "Azuredevops"
}

data "azurerm_image" "main" {
  name = "AlvaroImage01"
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.main.location
  resource_group_name = "Azuredevops"
  tags = {
    project = "1"
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = "Azuredevops"
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-securityGroup01"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = "Azuredevops"
  tags = {
    project = "1"
  }
}

resource "azurerm_network_security_rule" "main" {
  name                        = "Allow inbound traffic within the virtual network"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = "Azuredevops"
  network_security_group_name = azurerm_network_security_group.main.name
}




# --------------------------------------------Load balancer and availability set ---------------------------------------------------------------
resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}PublicIp1"
  resource_group_name = "Azuredevops"
  location            = data.azurerm_resource_group.main.location
  allocation_method   = "Static"
  tags = {
    project = "1"
  }
}

resource "azurerm_lb" "main" {
  name = "${var.prefix}LoadBalancer"
  location = data.azurerm_resource_group.main.location
  resource_group_name = "Azuredevops"

  frontend_ip_configuration {
    name = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
   loadbalancer_id     = azurerm_lb.main.id
   name                = "BackEndAddressPool"
 }

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.numberOfVMs
  network_interface_id    = element(azurerm_network_interface.main.*.id, count.index)
  ip_configuration_name   = "ipConfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

 resource "azurerm_network_interface" "main" {
   count               = var.numberOfVMs
   name                = "acctni${count.index}"
   location            = data.azurerm_resource_group.main.location
   resource_group_name = "Azuredevops"

   ip_configuration {
     name                          = "ipConfiguration"
     subnet_id                     = azurerm_subnet.internal.id
     private_ip_address_allocation = "Dynamic"
   }
 }
/*
 resource "azurerm_managed_disk" "main" {
   count                = var.numberOfVMs
   name                 = "datadisk_existing_${count.index}"
   location             = data.azurerm_resource_group.main.location
   resource_group_name  = "Azuredevops"
   storage_account_type = "Standard_LRS"
   create_option        = "Empty"
   disk_size_gb         = "1023"
 }
*/
 resource "azurerm_availability_set" "avset" {
   name                         = "avset"
   location                     = data.azurerm_resource_group.main.location
   resource_group_name          = "Azuredevops"
   platform_fault_domain_count  = 2
   platform_update_domain_count = 2
   managed                      = true
 }

 resource "azurerm_linux_virtual_machine" "main" {
   count                 = var.numberOfVMs
   name                  = "acctvm${count.index}"
   location              = data.azurerm_resource_group.main.location
   availability_set_id   = azurerm_availability_set.avset.id
   resource_group_name   = data.azurerm_resource_group.main.name
   network_interface_ids = [element(azurerm_network_interface.main.*.id, count.index)]
   size               = "Standard_DS1_v2"
   disable_password_authentication = false
   # Uncomment this line to delete the OS disk automatically when deleting the VM
   # delete_os_disk_on_termination = true

   # Uncomment this line to delete the data disks automatically when deleting the VM
   # delete_data_disks_on_termination = true

   os_disk {
     name              = "myosdisk${count.index}"
     caching           = "ReadWrite"
     storage_account_type = "Standard_LRS"
   }

   # Optional data disks
  /*
   storage_data_disk {
     name              = "datadisk_new_${count.index}"
     managed_disk_type = "Standard_LRS"
     create_option     = "Empty"
     lun               = 0
     disk_size_gb      = "1023"
   }


   storage_data_disk {
     name            = element(azurerm_managed_disk.main.*.name, count.index)
     managed_disk_id = element(azurerm_managed_disk.main.*.id, count.index)
     create_option   = "Attach"
     lun             = 1
     disk_size_gb    = element(azurerm_managed_disk.main.*.disk_size_gb, count.index)
   }
 */
   admin_username = "${var.username}"
   admin_password = "${var.password}"

   source_image_id = data.azurerm_image.main.id

   tags = {
     project = "1"
   }
 }
