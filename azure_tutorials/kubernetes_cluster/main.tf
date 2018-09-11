# All elements are tagged with "Terraform Demo"

# We're using the random_id generator to create a unique ID to be used for
# unique names of resources in this lab
resource "random_id" "randomId" {

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
resource azurerm_network_security_group "test_advanced_network" {
  name                = "akc-1-nsg"
  location            = "${azurerm_resource_group.myterraformgroup.location}"
  resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
}

resource "azurerm_virtual_network" "test_advanced_network" {
  name                = "akc-1-vnet"
  location            = "${azurerm_resource_group.myterraformgroup.location}"
  resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "test_subnet" {
  name                      = "akc-1-subnet"
  resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"
  network_security_group_id = "${azurerm_network_security_group.test_advanced_network.id}"
  address_prefix            = "10.1.0.0/24"
  virtual_network_name      = "${azurerm_virtual_network.test_advanced_network.name}"
}

resource "azurerm_kubernetes_cluster" "test" {
  name       = "akc-1"
  location   = "${azurerm_resource_group.myterraformgroup.location}"
  dns_prefix = "akc-1"

  resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

  linux_profile {
    admin_username = "acctestuser1"

    ssh_key {
      key_data = "${var.access_key}"
    }
  }

  agent_pool_profile {
    name    = "agentpool"
    count   = "2"
    vm_size = "Standard_DS2_v2"
    os_type = "Linux"

    # Required for advanced networking
    vnet_subnet_id = "${azurerm_subnet.test_subnet.id}"
  }

  # This is annoying because the Azure Resource Manager module already sets these up via the
  # ARM_* environment variables.  Now we have to have two sets with the same values.
  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  network_profile {
    network_plugin = "azure"
  }
}