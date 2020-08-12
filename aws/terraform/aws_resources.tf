variable "access_key" {
}

variable "secret_key" {
}

variable "AWS_REGION" {
  type    = string
  default = "eu-west-2"
}

variable "AWS_CIDR" {
  type    = string
  default = "192.168.0.0/16"
}

variable "AWS_UNDERLAY_SUBNET" {
  type    = string
  default = "192.168.1.0/24"
}

variable "UNDERLAY_SUBNETMASK" {
  type    = string
  default = "255.255.255.0"
}
variable "AWS_FRONT_SUBNET" {
  type    = string
  default = "10.1.1.0/24"
}

variable "VM_USER" {
  type    = string
  default = "ramesh"
}

variable "VM_SSH_KEY_FILE" {
  type    = string
  default = "~/.ssh/ssh_private_key"
}

variable "VM_SSH_PUBLICKEY_FILE" {
  type    = string
  default = "~/.ssh/ssh_public_key"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = [
      "*ubuntu*lts*",
    ]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

provider "aws" {
  region     = var.AWS_REGION
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "default-vpc" {
  cidr_block = var.AWS_CIDR
  tags = {
    Name        = "default-vpc"
    environment = "l2project"
  }
}

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.default-vpc.id
  tags = {
    Name        = "internet-gw"
    environment = "l2project"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }
  tags = {
    Name        = "l2project-defaultroute"
    environment = "l2project"
  }
}

resource "aws_subnet" "underlay-subnet" {
  vpc_id            = aws_vpc.default-vpc.id
  cidr_block        = var.AWS_UNDERLAY_SUBNET
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name        = "underlay-subnet"
    environment = "l2project"
  }
}

resource "aws_subnet" "front-subnet" {
  vpc_id            = aws_vpc.default-vpc.id
  cidr_block        = var.AWS_FRONT_SUBNET
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name        = "front-subnet"
    environment = "l2project"
  }
}

resource "aws_route_table_association" "underlay-subnet-route" {
  subnet_id      = aws_subnet.underlay-subnet.id
  route_table_id = aws_route_table.public.id
  depends_on = [
    aws_route_table.public,
    aws_subnet.underlay-subnet,
  ]
}

resource "aws_route_table_association" "front-subnet-route" {
  subnet_id      = aws_subnet.front-subnet.id
  route_table_id = aws_route_table.public.id
  depends_on = [
    aws_route_table.public,
    aws_subnet.front-subnet,
  ]
}

resource "aws_key_pair" "VM_SSH_KEY" {
  key_name   = "vm_ssh_key"
  public_key = file(var.VM_SSH_PUBLICKEY_FILE)
}

resource "aws_security_group" "ssh_tunnel_web" {
  name        = "allow_ssh_tunnel_web"
  description = "Allow ssh tunnel traffic"
  vpc_id      = aws_vpc.default-vpc.id
}

resource "aws_security_group_rule" "vxlan4789_In" {
  type              = "ingress"
  from_port         = 4789
  to_port           = 4789
  protocol          = 17
  security_group_id = aws_security_group.ssh_tunnel_web.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vxlan4789_Out" {
  type              = "egress"
  from_port         = 4789
  to_port           = 4789
  protocol          = 17
  security_group_id = aws_security_group.ssh_tunnel_web.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vxlan8472_In" {
  type              = "ingress"
  from_port         = 8472
  to_port           = 8472
  protocol          = 17
  security_group_id = aws_security_group.ssh_tunnel_web.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vxlan8472_Out" {
  type              = "egress"
  from_port         = 8472
  to_port           = 8472
  protocol          = 17
  security_group_id = aws_security_group.ssh_tunnel_web.id
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "geneve6081_In" {
  type              = "ingress"
  from_port         = 6081
  to_port           = 6081
  protocol          = 17
  security_group_id = aws_security_group.ssh_tunnel_web.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "geneve6081_Out" {
  type              = "egress"
  from_port         = 6081
  to_port           = 6081
  protocol          = 17
  security_group_id = aws_security_group.ssh_tunnel_web.id
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "external_443_Out" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = 6
  security_group_id = aws_security_group.ssh_tunnel_web.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "external_80_Out" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = 6
  security_group_id = aws_security_group.ssh_tunnel_web.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "external_ssh_In" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = 6
  security_group_id = aws_security_group.ssh_tunnel_web.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_network_interface" "Router_Front_NIC" {
  subnet_id = aws_subnet.front-subnet.id
  security_groups = [
    aws_security_group.ssh_tunnel_web.id,
  ]
  tags = {
    Name        = "Router_Front_NIC"
    environment = "l2project"
  }
}

resource "aws_network_interface" "Router_Backend_NIC" {
  subnet_id         = aws_subnet.underlay-subnet.id
  security_groups = [
    aws_security_group.ssh_tunnel_web.id,
  ]
  tags = {
    Name        = "Router_Backend_NIC"
    environment = "l2project"
  }
}
resource "aws_network_interface" "Client1_NIC" {
  subnet_id         = aws_subnet.underlay-subnet.id
  security_groups = [
    aws_security_group.ssh_tunnel_web.id,
  ]
  tags = {
    Name        = "Client1_NIC"
    environment = "l2project"
  }
}

resource "aws_eip" "router" {
  vpc               = true
  network_interface = aws_network_interface.Router_Front_NIC.id
}

resource "aws_eip" "client1" {
  vpc               = true
  network_interface = aws_network_interface.Client1_NIC.id
}

resource "aws_instance" "layer2-aws-client1" {
  instance_type     = "t2.small"
  ami               = data.aws_ami.ubuntu.id
  key_name          = aws_key_pair.VM_SSH_KEY.key_name
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name        = "layer2-aws-client1"
    environment = "l2project"
  }
  network_interface {
    network_interface_id = aws_network_interface.Client1_NIC.id
    device_index         = 0
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_eip.client1.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
    inline = [
      "sudo adduser --disabled-password --gecos \"\"  ${var.VM_USER}",
      "sudo mkdir /home/${var.VM_USER}/.ssh",
      "sudo cp -a /home/ubuntu/.ssh/* /home/${var.VM_USER}/.ssh/",
      "sudo echo '${var.VM_USER} ALL=(ALL) NOPASSWD: ALL' > ${var.VM_USER}",
      "sudo mv ${var.VM_USER} /etc/sudoers.d/",
      "sudo chown -R 0:0 /etc/sudoers.d/${var.VM_USER}",
      "sudo chown -R ${var.VM_USER}:${var.VM_USER} /home/${var.VM_USER}/.ssh",
      "sudo hostname layer2-aws-client1",
    ]
  }
  provisioner "file" {
    source      = "../common/tools.sh"
    destination = "/tmp/tools.sh"
    connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = aws_eip.client1.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = aws_eip.client1.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
    inline = [
      "chmod +x /tmp/tools.sh",
      "sudo bash -x /tmp/tools.sh",
      "sudo pkill -u ubuntu",
      "sudo deluser ubuntu",
    ]
  }
}

resource "aws_instance" "layer2-aws-router" {
  instance_type     = "t2.small"
  ami               = data.aws_ami.ubuntu.id
  key_name          = aws_key_pair.VM_SSH_KEY.key_name
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name        = "layer2-aws-router"
    environment = "l2project"
  }
  network_interface {
    network_interface_id = aws_network_interface.Router_Front_NIC.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.Router_Backend_NIC.id
    device_index         = 1
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_eip.router.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
    inline = [
      "sudo adduser --disabled-password --gecos \"\"  ${var.VM_USER}",
      "sudo mkdir /home/${var.VM_USER}/.ssh",
      "sudo cp -a /home/ubuntu/.ssh/* /home/${var.VM_USER}/.ssh/",
      "sudo echo '${var.VM_USER} ALL=(ALL) NOPASSWD: ALL' > ${var.VM_USER}",
      "sudo mv ${var.VM_USER} /etc/sudoers.d/",
      "sudo chown -R 0:0 /etc/sudoers.d/${var.VM_USER}",
      "sudo chown -R ${var.VM_USER}:${var.VM_USER} /home/${var.VM_USER}/.ssh",
      "sudo hostname layer2-aws-router",
    ]
  }
  provisioner "file" {
    source      = "../common/tools.sh"
    destination = "/tmp/tools.sh"
    connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = aws_eip.router.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = aws_eip.router.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
    inline = [
      "chmod +x /tmp/tools.sh",
      "sudo bash -x /tmp/tools.sh",
      "sudo pkill -u ubuntu",
      "sudo deluser ubuntu",
    ]
  }
  provisioner "file" {
    source      = "../common/dhclient_metric.sh"
    destination = "/tmp/dhclient_metric.sh"
    connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = aws_eip.router.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = aws_eip.router.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
    inline = [
      "chmod +x /tmp/dhclient_metric.sh",
      "sudo bash -x /tmp/dhclient_metric.sh ",
    ]
  }  
}
output "router_backend_ip" {
  value = aws_network_interface.Router_Backend_NIC.private_ip
}
output "client1_ip" {
  value = aws_network_interface.Client1_NIC.private_ip
}
output "router_public_ip" {
  value = aws_eip.router.public_ip
}
output "client1_public_ip" {
  value = aws_eip.client1.public_ip
}

