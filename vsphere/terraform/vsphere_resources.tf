variable "VSPHERE_USER" {
}

variable "VSPHERE_PASSWORD" {
}

variable "ESXI_HOST" {
  type    = string
  default = "localhost.localdomain"
}

variable "ESXI_DATACENTER" {
  type    = string
  default = "ha-datacenter"
}

variable "ESXI_DATASTORE" {
  type    = string
  default = "data"
}

variable "ESXI_ROUTER_NAME" {
  type    = string
  default = "layer2-vsphere-router"
}

variable "ESXI_CLIENT1_NAME" {
  type    = string
  default = "layer2-vsphere-client1"
}

variable "VSPHERE_CLIENT1_IP" {
  type    = string
  default = "192.168.1.15"
}

variable "VSPHERE_ROUTER_BACKEND_IP" {
  type    = string
  default = "192.168.1.14"
}

variable "UNDERLAY_SUBNETMASK" {
  type    = string
  default = "255.255.255.0"
}

variable "VM_USER" {
  type    = string
  default = "ramesh"
}

variable "VM_SSH_KEY_FILE" {
  type    = string
  default = "$HOME/.ssh/ssh_key.pem"
}

variable "CLIENT1_MGMT_IP" {
  type    = string
  default = "192.168.1.33"
}

variable "ROUTER_MGMT_IP" {
  type    = string
  default = "192.168.1.32"
}

provider "vsphere" {
  user           = var.VSPHERE_USER
  password       = var.VSPHERE_PASSWORD
  vsphere_server = var.ESXI_HOST

  # If you have a self-signed cert
  allow_unverified_ssl = true
  persist_session      = false
}

data "vsphere_datacenter" "dc" {
  name = var.ESXI_DATACENTER
}

data "vsphere_resource_pool" "pool" {
  name          = "resource-pool-1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.ESXI_HOST
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "data" {
  name          = var.ESXI_DATASTORE
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_host_virtual_switch" "l2switch_1" {
  name             = "layer2switch_1"
  host_system_id   = data.vsphere_host.host.id
  network_adapters = []
  active_nics      = []
  standby_nics     = []
}

resource "vsphere_host_port_group" "backend" {
  name                = "backend"
  host_system_id      = data.vsphere_host.host.id
  virtual_switch_name = vsphere_host_virtual_switch.l2switch_1.name
  vlan_id             = 0
  allow_promiscuous   = true
}

data "vsphere_network" "backend" {
  name          = vsphere_host_port_group.backend.name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "null_resource" "poweron" {
  depends_on = [vsphere_host_port_group.backend]
  connection {
    type     = "ssh"
    user     = var.VSPHERE_USER
    password = var.VSPHERE_PASSWORD
    host     = var.ESXI_HOST
  }

  provisioner "remote-exec" {
    inline = [
      "vim-cmd vmsvc/power.on $(vim-cmd vmsvc/getallvms | grep ${var.ESXI_ROUTER_NAME} | awk '{print $1}')",
      "vim-cmd vmsvc/power.on $(vim-cmd vmsvc/getallvms | grep ${var.ESXI_CLIENT1_NAME} | awk '{print $1}')",
      "echo ${var.VM_SSH_KEY_FILE} >> test",
    ]
  }
}

resource "null_resource" "client_interface_config" {
  depends_on = [null_resource.poweron]
  connection {
    type        = "ssh"
    user        = var.VM_USER
    private_key = file(var.VM_SSH_KEY_FILE)
    host        = var.CLIENT1_MGMT_IP
    timeout     = "5m"
  }
  provisioner "file" {
    source      = "../common/interface.sh"
    destination = "/tmp/interface.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/interface.sh",
      "/tmp/interface.sh ${var.VSPHERE_CLIENT1_IP} ${var.UNDERLAY_SUBNETMASK}",
    ]
  }
}

resource "null_resource" "router_interface_config" {
  depends_on = [null_resource.poweron]
  connection {
    type        = "ssh"
    user        = var.VM_USER
    private_key = file(var.VM_SSH_KEY_FILE)
    host        = var.ROUTER_MGMT_IP
    timeout     = "5m"
  }
  provisioner "file" {
    source      = "../common/interface.sh"
    destination = "/tmp/interface.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/interface.sh",
      "/tmp/interface.sh ${var.VSPHERE_ROUTER_BACKEND_IP} ${var.UNDERLAY_SUBNETMASK}",
    ]
  }
}

