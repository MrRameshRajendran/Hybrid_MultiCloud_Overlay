variable "access_key" {
}

variable "secret_key" {
}

variable "ALI_REGION" {
  type    = string
  default = "eu-west-1"
}

variable "ALI_CIDR" {
  type    = string
  default = "192.168.0.0/16"
}

variable "ALI_UNDERLAY_SUBNET" {
  type    = string
  default = "192.168.1.0/24"
}
variable "ALI_FRONT_SUBNET" {
  type    = string
  default = "192.168.0.0/24"
}

variable "ALI_VM_USER" {
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

data "alicloud_images" "default" {
  name_regex  = "^ubuntu"
  most_recent = true
  owners      = "system"
}

data "alicloud_zones" "zones_ds" {
  available_instance_type = "ecs.g6.large"
}
provider "alicloud" {
  region     = var.ALI_REGION
  access_key = var.access_key
  secret_key = var.secret_key
}
resource "alicloud_vpc" "default-vpc" {
  cidr_block = var.ALI_CIDR
}

resource "alicloud_vswitch" "front-vswitch" {
  name              = "front-vswitch"
  cidr_block        = var.ALI_FRONT_SUBNET
  vpc_id            = alicloud_vpc.default-vpc.id
  availability_zone = data.alicloud_zones.zones_ds.zones[0].id
}

resource "alicloud_vswitch" "backend-vswitch" {
  name              = "backend-vswitch"
  cidr_block        = var.ALI_UNDERLAY_SUBNET
  vpc_id            = alicloud_vpc.default-vpc.id
  availability_zone = data.alicloud_zones.zones_ds.zones[0].id
}

resource "alicloud_nat_gateway" "internet-gw" {
  vpc_id        = alicloud_vpc.default-vpc.id
  specification = "Small"
  name          = "gateway"
}
resource "alicloud_key_pair" "VM_SSH_KEY" {
  key_name   = "vm_ssh_key"
  public_key = file(var.VM_SSH_PUBLICKEY_FILE)
}

resource "alicloud_security_group" "ssh_icmp_tunnel_web" {
  name        = "allow_ssh_icmp_tunnel"
  description = "Allow ssh icmp vxlan traffic"
  vpc_id      = alicloud_vpc.default-vpc.id
}

resource "alicloud_security_group_rule" "vxlan4789_In" {
  type              = "ingress"
  port_range        = "4789/4789"
  ip_protocol       = "udp"
  security_group_id = alicloud_security_group.ssh_icmp_tunnel_web.id
  cidr_ip           = "0.0.0.0/0"
  policy            = "accept"
}

resource "alicloud_security_group_rule" "vxlan4789_Out" {
  type              = "egress"
  port_range        = "4789/4789"
  ip_protocol       = "udp"
  security_group_id = alicloud_security_group.ssh_icmp_tunnel_web.id
  cidr_ip           = "0.0.0.0/0"
  policy            = "accept"
}

resource "alicloud_security_group_rule" "vxlan8472_In" {
  type              = "ingress"
  port_range        = "8472/8472"
  ip_protocol       = "udp"
  security_group_id = alicloud_security_group.ssh_icmp_tunnel_web.id
  cidr_ip           = "0.0.0.0/0"
  policy            = "accept"
}

resource "alicloud_security_group_rule" "vxlan8472_Out" {
  type              = "egress"
  port_range        = "8472/8472"
  ip_protocol       = "udp"
  security_group_id = alicloud_security_group.ssh_icmp_tunnel_web.id
  cidr_ip           = "0.0.0.0/0"
  policy            = "accept"
}
resource "alicloud_security_group_rule" "geneve6081_In" {
  type              = "ingress"
  port_range        = "6081/6081"
  ip_protocol       = "udp"
  security_group_id = alicloud_security_group.ssh_icmp_tunnel_web.id
  cidr_ip           = "0.0.0.0/0"
  policy            = "accept"
}

resource "alicloud_security_group_rule" "geneve6081_Out" {
  type              = "egress"
  port_range        = "6081/6081"
  ip_protocol       = "udp"
  security_group_id = alicloud_security_group.ssh_icmp_tunnel_web.id
  cidr_ip           = "0.0.0.0/0"
  policy            = "accept"
}
resource "alicloud_security_group_rule" "tcp443_Out" {
  type              = "egress"
  port_range        = "443/443"
  ip_protocol       = "tcp"
  security_group_id = alicloud_security_group.ssh_icmp_tunnel_web.id
  cidr_ip           = "0.0.0.0/0"
  policy            = "accept"
}
resource "alicloud_security_group_rule" "tcp80_Out" {
  type              = "egress"
  port_range        = "80/80"
  ip_protocol       = "tcp"
  security_group_id = alicloud_security_group.ssh_icmp_tunnel_web.id
  cidr_ip           = "0.0.0.0/0"
  policy            = "accept"
}

resource "alicloud_security_group_rule" "ssh_In" {
  type              = "ingress"
  port_range        = "22/22"
  ip_protocol       = "tcp"
  security_group_id = alicloud_security_group.ssh_icmp_tunnel_web.id
  cidr_ip           = "0.0.0.0/0"
  policy            = "accept"
}

resource "alicloud_security_group_rule" "icmp_In" {
  type              = "ingress"
  port_range        = "-1/-1"
  ip_protocol       = "icmp"
  security_group_id = alicloud_security_group.ssh_icmp_tunnel_web.id
  cidr_ip           = "0.0.0.0/0"
  policy            = "accept"
}

resource "alicloud_security_group_rule" "icmp_Out" {
  type              = "egress"
  port_range        = "-1/-1"
  ip_protocol       = "icmp"
  security_group_id = alicloud_security_group.ssh_icmp_tunnel_web.id
  cidr_ip           = "0.0.0.0/0"
  policy            = "accept"
}


resource "alicloud_network_interface" "Router_Backend_NIC" {
  name            = "Router_Backend_NIC"
  vswitch_id      = alicloud_vswitch.backend-vswitch.id
  security_groups = [alicloud_security_group.ssh_icmp_tunnel_web.id]
}

resource "alicloud_network_interface_attachment" "router_backend_nic_attachment" {
  instance_id          = alicloud_instance.layer2-ali-router.id
  network_interface_id = alicloud_network_interface.Router_Backend_NIC.id
}



resource "alicloud_instance" "layer2-ali-client1" {
  availability_zone          = data.alicloud_zones.zones_ds.zones[0].id
  security_groups            = [alicloud_security_group.ssh_icmp_tunnel_web.id]   
  key_name                   = alicloud_key_pair.VM_SSH_KEY.key_name
  instance_type              = "ecs.g6.large"
  system_disk_category       = "cloud_efficiency"
  image_id                   = data.alicloud_images.default.images[0].id
  instance_name              = "layer2-ali-client1"
  vswitch_id                 = alicloud_vswitch.backend-vswitch.id
  internet_max_bandwidth_out = 10
  timeouts {
    create = "15m"
    delete = "15m"
  }    
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      host        = alicloud_instance.layer2-ali-client1.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
    inline = [
      "sudo adduser --disabled-password --gecos \"\"  ${var.ALI_VM_USER}",
      "sudo mkdir /home/${var.ALI_VM_USER}/.ssh",
      "sudo cp -a /root/.ssh/* /home/${var.ALI_VM_USER}/.ssh/ ",
      "sudo echo '${var.ALI_VM_USER} ALL=(ALL) NOPASSWD: ALL' > ${var.ALI_VM_USER}",
      "sudo mv ${var.ALI_VM_USER} /etc/sudoers.d/",
      "sudo chown -R 0:0 /etc/sudoers.d/${var.ALI_VM_USER}",
      "sudo chown -R ${var.ALI_VM_USER}:${var.ALI_VM_USER} /home/${var.ALI_VM_USER}/.ssh",
      "sudo hostname layer2-ali-client1",
    ]
  }
  provisioner "file" {
    source      = "../common/tools.sh"
    destination = "/tmp/tools.sh"
    connection {
      type        = "ssh"
      user        = var.ALI_VM_USER
      host        = alicloud_instance.layer2-ali-client1.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.ALI_VM_USER
      host        = alicloud_instance.layer2-ali-client1.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
    inline = [
      "chmod +x /tmp/tools.sh",
      "sudo bash -x /tmp/tools.sh",
      "sudo iptables -F",
    ]
  }
}

resource "alicloud_instance" "layer2-ali-router" {
  availability_zone          = data.alicloud_zones.zones_ds.zones[0].id
  security_groups            = [alicloud_security_group.ssh_icmp_tunnel_web.id] 
  key_name                   = alicloud_key_pair.VM_SSH_KEY.key_name
  instance_type              = "ecs.g6.large"
  system_disk_category       = "cloud_efficiency"
  image_id                   = data.alicloud_images.default.images[0].id
  instance_name              = "layer2-ali-router"
  vswitch_id                 = alicloud_vswitch.front-vswitch.id
  internet_max_bandwidth_out = 10
  timeouts {
    create = "15m"
    delete = "15m"
  }    
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      host        = alicloud_instance.layer2-ali-router.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
    inline = [
      "sudo adduser --disabled-password --gecos \"\"  ${var.ALI_VM_USER}",
      "sudo mkdir /home/${var.ALI_VM_USER}/.ssh",
      "sudo cp -a /root/.ssh/* /home/${var.ALI_VM_USER}/.ssh/",
      "sudo echo '${var.ALI_VM_USER} ALL=(ALL) NOPASSWD: ALL' > ${var.ALI_VM_USER}",
      "sudo mv ${var.ALI_VM_USER} /etc/sudoers.d/",
      "sudo chown -R 0:0 /etc/sudoers.d/${var.ALI_VM_USER}",
      "sudo chown -R ${var.ALI_VM_USER}:${var.ALI_VM_USER} /home/${var.ALI_VM_USER}/.ssh",
      "sudo hostname layer2-ali-router",
    ]
  }
  provisioner "file" {
    source      = "../common/tools.sh"
    destination = "/tmp/tools.sh"
    connection {
      type        = "ssh"
      user        = var.ALI_VM_USER
      host        = alicloud_instance.layer2-ali-router.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.ALI_VM_USER
      host        = alicloud_instance.layer2-ali-router.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
    inline = [
      "chmod +x /tmp/tools.sh",
      "sudo bash -x /tmp/tools.sh",
      "sudo iptables -F",
    ]
  }
  provisioner "file" {
    source      = "../common/dhclient_metric.sh"
    destination = "/tmp/dhclient_metric.sh"
    connection {
      type        = "ssh"
      user        = var.ALI_VM_USER
      host        = alicloud_instance.layer2-ali-router.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
  }
}
resource "null_resource" "backend_interface_config" {
  depends_on = [alicloud_network_interface_attachment.router_backend_nic_attachment]
  connection {
      type        = "ssh"
      user        = var.ALI_VM_USER
      host        = alicloud_instance.layer2-ali-router.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
  }
  provisioner "file" {
    source      = "../common/dhclient_metric.sh"
    destination = "/tmp/dhclient_metric.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/dhclient_metric.sh",
      "sudo bash -x /tmp/dhclient_metric.sh ",
    ]
  } 
}
output "router_backend_ip" {
  value = alicloud_network_interface.Router_Backend_NIC.private_ip
}
output "client1_ip" {
  value = alicloud_instance.layer2-ali-client1.private_ip
}
output "router_public_ip" {
  value = alicloud_instance.layer2-ali-router.public_ip
}
output "client1_public_ip" {
  value = alicloud_instance.layer2-ali-client1.public_ip
}

