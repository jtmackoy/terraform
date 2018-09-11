# All elements are tagged with "Terraform Demo"

# We're using the random_id generator to create a unique ID to be used for
# unique names of resources in this lab
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group changes or 
        # is created for the first time
        resource_group = "${azurerm_resource_group.myterraformgroup.name}"
    }

    byte_length = 8
}
# Create Azure Resource Group
resource "azurerm_resource_group" "myterraformgroup" {
    # Adding the random number generated to the resource group name - for uniqueness
    name     = "myResourceGroup${random_id.randomId.hex}"
    location = "eastus"

    tags {
        environment = "Terraform Demo"
    }
}
# Allocate an Azure Public IP
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "eastus"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "Terraform Demo"
    }
}
# Create an Azure network security group to allow SSH
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Terraform Demo"
    }
}
# Create azure network interface for the VM and bind the Public IP to it
resource "azurerm_network_interface" "myterraformnic" {
    name                = "myNIC"
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }

    tags {
        environment = "Terraform Demo"
    }
}
# Create an Azure storage account for logging info
resource "azurerm_storage_account" "mystorageaccount" {
    # Adding the random number generated to the resource group name - for uniqueness
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
    location            = "eastus"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "Terraform Demo"
    }
}