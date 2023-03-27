data "azurerm_client_config" "current" {}

# Create Resource Group
resource "azurerm_resource_group" "rg1" {
  name     = var.resource_group_name
  location = var.location
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

# Create bastion subnet
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.0.224/27"]
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg1" {
  name                = var.security_group_name
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
}

resource "azurerm_subnet_network_security_group_association" "nsg1_subnet1" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

# Create public IP for Bastion
resource "azurerm_public_ip" "nic1_ip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method   = "Static"
  sku = "Standard"
}

#Create bastion to connect to VMs
resource "azurerm_bastion_host" "bastion" {
  name                = var.bastion_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                 = "${var.bastion_name}-conf"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.nic1_ip.id
  }
}

# Create network interface
resource "azurerm_network_interface" "nic1" {
  name                = var.nic1_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "${var.nic1_name}-conf"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Get admin password from keyvault
data "azurerm_key_vault" "kv" {
  name                = var.keyvault_name
  resource_group_name = var.keyvault_rg
}

data "azurerm_key_vault_secret" "kv_secret" {
  name      = var.keyvault_secret
  key_vault_id = data.azurerm_key_vault.kv.id
}

# Create Windows Server
resource "azurerm_windows_virtual_machine" "windows-vm" {
  depends_on=[azurerm_network_interface.nic1]
  name                  = var.win_vm1_name
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg1.name
  size                  = "Standard_B1ms"
  network_interface_ids = [azurerm_network_interface.nic1.id]
  
  computer_name  = var.win_vm1_name
  admin_username = var.win_vm1_admin
  admin_password = data.azurerm_key_vault_secret.kv_secret.value
 
  os_disk {
    name                 = "${var.win_vm1_name}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.win_vm1_sku
    version   = "latest"
  }
  enable_automatic_updates = true
  provision_vm_agent       = true
}

resource "azurerm_automation_account" "automation_acc" {
  name                = "lt-tf-win-auto-account"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"
}

# Install DSC modules used in automation

resource "azurerm_automation_module" "psdsc" {
  name                    = "PSDesiredStateConfiguration"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_acc.name

  module_link {
    uri = "https://devopsgallerystorage.blob.core.windows.net/packages/psdesiredstateconfiguration.3.0.0-beta1.nupkg"
  }
}

resource "azurerm_automation_module" "compdsc" {
  name                    = "ComputerManagementDsc"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_acc.name

  module_link {
    uri = "https://devopsgallerystorage.blob.core.windows.net/packages/computermanagementdsc.9.0.0.nupkg"
  }
}

resource "azurerm_automation_module" "addsc" {
  name                    = "ActiveDirectoryDsc"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_acc.name

  module_link {
    uri = "https://devopsgallerystorage.blob.core.windows.net/packages/activedirectorydsc.6.2.0.nupkg"
  }
}

# Setup variables used in scripts
resource "azurerm_automation_variable_string" "DomainName" {
  name                    = "DomainName"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_acc.name
  value                   = var.ad_domainname
}

resource "azurerm_automation_variable_string" "DomainDN" {
  name                    = "DomainDN"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_acc.name
  value                   = var.ad_domaindn
}

# Setup credential used in DSC automation
resource "azurerm_automation_credential" "example" {
  name                    = "DomainAdmin"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_acc.name
  username                = var.win_vm1_admin
  password                = data.azurerm_key_vault_secret.kv_secret.value
}

# Install DSC powershell script
resource "azurerm_automation_dsc_configuration" "win_adds" {
  name                    = "DC1"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_acc.name
  location                = var.location
  content_embedded        = file("${path.module}/DSC/win-adds.ps1")
}
