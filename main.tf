data "azurerm_client_config" "current" {}

# Create Resource Group
resource "azurerm_resource_group" "rg1" {
  name     = var.resource_group_name
  location = var.location
  tags = {
   Environment = "Terraform Getting Started"
   Team = "DevOps"
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet1" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg1.name
}
  
# Create subnet
resource "azurerm_subnet" "subnet1" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.1.0/24"]
}