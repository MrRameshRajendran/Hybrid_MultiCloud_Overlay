variable "subscription_id" {
}

variable "client_id" {
}

variable "client_secret" {
}

variable "tenant_id" {
}

variable "AZURE_LOCATION" {
  type    = string
  default = "westeurope"
}
variable "AZURE_CIDR" {
  type    = string
  default = "192.168.0.0/16"
}
variable "AZURE_UNDERLAY_SUBNET" {
  type    = string
  default = "192.168.1.0/24"
}
variable "AZURE_FRONT_SUBNET" {
  type    = string
  default = "192.168.0.0/24"
}

variable "VM_USER" {
  type    = string
  default = "ramesh"
}

variable "VM_SSH_KEY_FILE" {
  type    = string
  default = "~/.ssh/ssh_key.pem"
}

variable "VM_SSH_PUBLICKEY_FILE" {
  type    = string
  default = "~/.ssh/ssh_public_key"
}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {}  
}

resource "azurerm_resource_group" "l2project_rg" {
  name     = "l2project_rg"
  location = var.AZURE_LOCATION

  tags = {
    environment = "l2project"
  }
}

resource "azurerm_virtual_network" "default-network" {
  name                = "default-network"
  address_space       = [var.AZURE_CIDR]
  location            = var.AZURE_LOCATION
  resource_group_name = azurerm_resource_group.l2project_rg.name
  tags = {
    environment = "l2project"
  }
}

resource "azurerm_subnet" "underlay-subnet" {
  name                      = "underlay-subnet"
  resource_group_name       = azurerm_resource_group.l2project_rg.name
  virtual_network_name      = azurerm_virtual_network.default-network.name
  address_prefixes          = [var.AZURE_UNDERLAY_SUBNET]
}

resource "azurerm_subnet" "front-subnet" {
  name                      = "front-subnet"
  resource_group_name       = azurerm_resource_group.l2project_rg.name
  virtual_network_name      = azurerm_virtual_network.default-network.name
  address_prefixes          = [var.AZURE_FRONT_SUBNET]
}

resource "azurerm_public_ip" "router" {
  name                = "router"
  location            = var.AZURE_LOCATION
  resource_group_name = azurerm_resource_group.l2project_rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = "routerip-dns"
  tags = {
    environment = "l2project"
  }
}

resource "azurerm_public_ip" "client1" {
  name                = "client1"
  location            = var.AZURE_LOCATION
  resource_group_name = azurerm_resource_group.l2project_rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = "client1ip-dns"
  tags = {
    environment = "l2project"
  }
}

resource "azurerm_network_security_group" "ssh-icmp-tunnel" {
  name                = "ssh-icmp-tunnel"
  location            = var.AZURE_LOCATION
  resource_group_name = azurerm_resource_group.l2project_rg.name

  security_rule {
    name                       = "SSH_In"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "vxlan4789_In"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "4789"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "vxlan4789_Out"
    priority                   = 1020
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "4789"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "vxlan8472_In"
    priority                   = 1030
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "8472"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "vxlan8472_Out"
    priority                   = 1040
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "8472"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "geneve6081_In"
    priority                   = 1050
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "6081"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "geneve6081_Out"
    priority                   = 1060
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "6081"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # ICMP is not currently supported by the terraform provider. Once it is fixed, this rule will be changed to ICMP only
  security_rule {
    name                       = "icmp_In"
    priority                   = 1070
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "icmp_Out"
    priority                   = 1080
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }  
  tags = {
    environment = "l2project"
  }
}
resource "azurerm_subnet_network_security_group_association" "front-security" {
  subnet_id                 = azurerm_subnet.front-subnet.id
  network_security_group_id = azurerm_network_security_group.ssh-icmp-tunnel.id
}
resource "azurerm_subnet_network_security_group_association" "underlay-security" {
  subnet_id                 = azurerm_subnet.underlay-subnet.id
  network_security_group_id = azurerm_network_security_group.ssh-icmp-tunnel.id
}
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.l2project_rg.name
  }

  byte_length = 8
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.l2project_rg.name
  location                 = var.AZURE_LOCATION
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "l2project"
  }
}

# Create network interface
resource "azurerm_network_interface" "Router_Front_NIC" {
  name                      = "Router_Front_NIC"
  location                  = var.AZURE_LOCATION
  resource_group_name       = azurerm_resource_group.l2project_rg.name
  ip_configuration {
    name                          = "Router_Front_NIC_Config"
    subnet_id                     = azurerm_subnet.front-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.router.id
  }

  tags = {
    environment = "l2project"
  }
}

resource "azurerm_network_interface" "Router_Backend_NIC" {
  name                      = "Router_Backend_NIC"
  location                  = var.AZURE_LOCATION
  resource_group_name       = azurerm_resource_group.l2project_rg.name
  ip_configuration {
    name                          = "Router_Backend_NIC_Config"
    subnet_id                     = azurerm_subnet.underlay-subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "l2project"
  }
}

resource "azurerm_network_interface" "Client1_NIC" {
  name                      = "Client1_NIC"
  location                  = var.AZURE_LOCATION
  resource_group_name       = azurerm_resource_group.l2project_rg.name
  ip_configuration {
    name                          = "Client1_NIC_Config"
    subnet_id                     = azurerm_subnet.underlay-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.client1.id
  }

  tags = {
    environment = "l2project"
  }
}

resource "azurerm_linux_virtual_machine" "layer2-azure-client1" {
  name                         = "layer2-azure-client1"
  location                     = var.AZURE_LOCATION
  resource_group_name          = azurerm_resource_group.l2project_rg.name
  size                         = "Standard_B1s"
  network_interface_ids        = [azurerm_network_interface.Client1_NIC.id] 
  computer_name                = "layer2-azure-client1"
  admin_username               = var.VM_USER
      
  os_disk {
    name                 = "client1-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username                        = var.VM_USER
    public_key                      = file(var.VM_SSH_PUBLICKEY_FILE)  
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storage_account.primary_blob_endpoint
  }

  tags = {
    environment = "l2project"
  }
}

resource "azurerm_linux_virtual_machine" "layer2-azure-router" {
  name                         = "layer2-azure-router"
  location                     = var.AZURE_LOCATION
  resource_group_name          = azurerm_resource_group.l2project_rg.name
  network_interface_ids        = [azurerm_network_interface.Router_Front_NIC.id, azurerm_network_interface.Router_Backend_NIC.id]
  size                         = "Standard_B1s"
  computer_name                = "layer2-azure-router"
  admin_username               = var.VM_USER
    
  os_disk {
    name                 = "router-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username                        = var.VM_USER
    public_key                      = file(var.VM_SSH_PUBLICKEY_FILE)  
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storage_account.primary_blob_endpoint
  }

  tags = {
    environment = "l2project"
  }
}

resource "null_resource" "router_config" {
  depends_on      = [ azurerm_linux_virtual_machine.layer2-azure-router, azurerm_public_ip.router] 
  connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = azurerm_public_ip.router.fqdn
      private_key = file(var.VM_SSH_KEY_FILE)
      agent       = false
      timeout     = "5m"
  }
  provisioner "file" {
    source      = "../common/tools.sh"
    destination = "/tmp/tools.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/tools.sh",
      "sudo echo '${var.VM_USER} ALL=(ALL) NOPASSWD: ALL' > ${var.VM_USER}",
      "sudo mv ${var.VM_USER} /etc/sudoers.d/",
      "sudo chown -R 0:0 /etc/sudoers.d/${var.VM_USER}",
      "sudo bash -x /tmp/tools.sh",
    ]
  }
}

resource "null_resource" "client1_config" {
  depends_on      = [ azurerm_linux_virtual_machine.layer2-azure-client1, azurerm_public_ip.client1] 
  connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = azurerm_public_ip.client1.fqdn
      private_key = file(var.VM_SSH_KEY_FILE)
      agent       = false
      timeout     = "5m"
  }
  provisioner "file" {
    source      = "../common/tools.sh"
    destination = "/tmp/tools.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/tools.sh",
      "sudo echo '${var.VM_USER} ALL=(ALL) NOPASSWD: ALL' > ${var.VM_USER}",
      "sudo mv ${var.VM_USER} /etc/sudoers.d/",
      "sudo chown -R 0:0 /etc/sudoers.d/${var.VM_USER}",
      "sudo bash -x /tmp/tools.sh",
    ]
  }
}

data "azurerm_public_ip" "router" {
  name                = azurerm_public_ip.router.name
  resource_group_name = azurerm_resource_group.l2project_rg.name
}
data "azurerm_public_ip" "client1" {
  name                = azurerm_public_ip.client1.name
  resource_group_name = azurerm_resource_group.l2project_rg.name
}

output "router_backend_ip" {
  value = azurerm_network_interface.Router_Backend_NIC.private_ip_address
}

output "client1_ip" {
  value = azurerm_network_interface.Client1_NIC.private_ip_address
}

output "router_public_ip" {
  value = data.azurerm_public_ip.router.ip_address
}

output "client1_public_ip" {
  value = data.azurerm_public_ip.client1.ip_address
}
