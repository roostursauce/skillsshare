# Creates a windows server 2025 Web server running IIS

# create initial resource group to contain the VM and related resources
resource "azurerm_resource_group" "rg" {
    location      = var.az_region
    name          = var.az_resource_group_name
}

# create VNet resource
resource "azurerm_virtual_network" "test_vnet" {
    name = "test-vnet-{$azurerm_resource_group.rg.location}"
    address_space = ["10.100.0.0/16"]
    location  = var.az_location
    resource_group_name = var.az_resource_group_name
}

# create subnet for the VM
resource "azurerm_subnet" "web_vm_subnet" {
    name  = "web_vm_subnet"
    resource_group_name = var.az_resource_group_name
    virtual_network_name = azurerm_virtual_network.test_vnet
    address_prefixes    =  ["10.100.1.0/24"]
}

# Create public IP for Web server and web endpoint
resource "azurerm_public_ip" "web_vm_ip" {
    name = "${var.az_vm_name}-public-ip"
    location = var.az_location
    resource_group_name = var.az_resource_group_name
    allocation_method = "Dynamic"
}

# create NSG and base rules
resource "azurerm_network_security_group" "web_vm_nsg" {
    name = "${var.az_vm_name}
    location = var.az_location
    resource_group_name = var.az_resource_group_name

    security_rule {
        name                       = "RDP"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = ["${var.your_current_public_ip}"]
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Web Inbound traffic"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Create a Web VM Network Interface and associate the public IP
resource "azurerm_network_interface" "web_vm_nic" {
  name                = "${var.az_vm_name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = var.az_resource_group_name

  ip_configuration {
    name                          = "web_vm_nic_configuration"
    subnet_id                     = azurerm_subnet.web_vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web_vm_ip.id
  }
}

# Link NSG to web vm nic configuration
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.web_vm_nic.id
  network_security_group_id = azurerm_network_security_group.web_vm_nsg.id
}

# Create boot diagnostics storage account 
resource "azurerm_storage_account" "vm_diag_storage_account" {
  name                     = "${var.az_vm_name}-diag"
  location                 = var.az_location
  resource_group_name      = var.az_resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create the VM and associate all previously created vm resources
resource "azurerm_windows_virtual_machine" "web_vm" {
    name            = var.az_vm_name
    admin_username  = var.admin_username
    admin_password  = var.admin_password
    location        = var.az_location
    resource_group_name = var.az_resource_group_name
    network_interface_ids = [azurerm_network_interface.web_vm_nic.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name = "vmOSDisk"
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-azure-edition"
    version   = "latest"
  }

  # Assign boot diagnostics storage account
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.vm_diag_storage_account.primary_blob_endpoint
  }

} 

# Install IIS web server to the virtual machine
resource "azurerm_virtual_machine_extension" "web_server_install" {
  name                       = "${var.az_vm_name}-wsi"
  virtual_machine_id         = azurerm_windows_virtual_machine.web_vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
  SETTINGS
}