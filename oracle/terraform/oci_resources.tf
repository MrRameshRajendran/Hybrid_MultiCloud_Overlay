variable "tenancy_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

variable "compartment_ocid" {
}

variable "OCI_REGION" {
  type    = string
  default = "uk-london-1"
}

variable "OCI_CIDR" {
  type    = string
  default = "192.168.0.0/16"
}

variable "OCI_UNDERLAY_SUBNET" {
  type    = string
  default = "192.168.1.0/24"
}
variable "UNDERLAY_SUBNETMASK" {
  type    = string
  default = "255.255.255.0"
}
variable "OCI_FRONT_SUBNET" {
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

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.compartment_ocid
  ad_number      = 1
}

data "oci_core_images" "supported_shape_images" {
  #Required
  compartment_id = var.compartment_ocid

  #Optional
  operating_system = "Canonical Ubuntu"
  shape            = "VM.Standard.E2.1.Micro"
  state            = "AVAILABLE"
  sort_by          = "TIMECREATED"
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.OCI_REGION
}

resource "oci_core_vcn" "default-vcn" {
  cidr_block     = var.OCI_CIDR
  compartment_id = var.compartment_ocid
  display_name   = "default-vcn"
  dns_label      = "defaultvcn"
}
resource "oci_core_internet_gateway" "internet-gw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.default-vcn.id
}
resource "oci_core_route_table" "route_table" {
  #Required
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.default-vcn.id
  route_rules {
    #Required
    network_entity_id = oci_core_internet_gateway.internet-gw.id
    destination = "0.0.0.0/0"
  }
}
resource "oci_core_subnet" "underlay-subnet" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  cidr_block          = var.OCI_UNDERLAY_SUBNET
  display_name        = "underlay-subnet"
  dns_label           = "underlaysubnet"
  security_list_ids   = [oci_core_vcn.default-vcn.default_security_list_id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.default-vcn.id
  route_table_id      = oci_core_route_table.route_table.id
  dhcp_options_id     = oci_core_vcn.default-vcn.default_dhcp_options_id
}

resource "oci_core_subnet" "front-subnet" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  cidr_block          = var.OCI_FRONT_SUBNET
  display_name        = "front-subnet"
  dns_label           = "frontsubnet"
  security_list_ids   = [oci_core_vcn.default-vcn.default_security_list_id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.default-vcn.id
  route_table_id      = oci_core_route_table.route_table.id
  dhcp_options_id     = oci_core_vcn.default-vcn.default_dhcp_options_id
}

resource "oci_core_public_ip" "router_publicip" {
  #Required
  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"

  #Optional
  freeform_tags = {
    "Project" = "Layer2Project"
  }
}

resource "oci_core_public_ip" "client1_publicip" {
  #Required
  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"

  #Optional
  freeform_tags = {
    "Project" = "Layer2Project"
  }
}
resource "oci_core_network_security_group" "ssh_icmp_tunnel_web" {
  compartment_id = var.compartment_ocid
  vcn_id      = oci_core_vcn.default-vcn.id
}

resource "oci_core_network_security_group_security_rule" "vxlan4789_In" {
  network_security_group_id = oci_core_network_security_group.ssh_icmp_tunnel_web.id
  description               = "vxlan4789_In"
  direction                 = "INGRESS"
  protocol                  = 17
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  udp_options {
    destination_port_range {
      min = 4789
      max = 4789
    }
  }  
}
resource "oci_core_network_security_group_security_rule" "vxlan4789_Out" {
  network_security_group_id = oci_core_network_security_group.ssh_icmp_tunnel_web.id
  description               = "vxlan4789_Out"
  direction                 = "EGRESS"
  protocol                  = 17
  destination_type          = "CIDR_BLOCK"  
  destination               = "0.0.0.0/0"
  udp_options {
    destination_port_range {
      min = 4789
      max = 4789
    }
  }  
}
resource "oci_core_network_security_group_security_rule" "vxlan8472_In" {
  network_security_group_id = oci_core_network_security_group.ssh_icmp_tunnel_web.id
  description               = "vxlan8472_In"
  direction                 = "INGRESS"
  protocol                  = 17
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  udp_options {
    destination_port_range {
      min = 8472
      max = 8472
    }
  }  
}
resource "oci_core_network_security_group_security_rule" "vxlan8472_Out" {
  network_security_group_id = oci_core_network_security_group.ssh_icmp_tunnel_web.id
  description               = "vxlan8472_Out"
  direction                 = "EGRESS"
  protocol                  = 17
  destination_type          = "CIDR_BLOCK"  
  destination               = "0.0.0.0/0"  
  udp_options {
    destination_port_range {
      min = 8472
      max = 8472
    }       
  }  
}
resource "oci_core_network_security_group_security_rule" "geneve6081_In" {
  network_security_group_id = oci_core_network_security_group.ssh_icmp_tunnel_web.id
  description               = "geneve6081_In"
  direction                 = "INGRESS"
  protocol                  = 17
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  udp_options {
    destination_port_range {
      min = 6081
      max = 6081
    }
  }  
}
resource "oci_core_network_security_group_security_rule" "geneve6081_Out" {
  network_security_group_id = oci_core_network_security_group.ssh_icmp_tunnel_web.id
  description               = "geneve6081_Out"
  direction                 = "EGRESS"
  protocol                  = 17
  destination_type          = "CIDR_BLOCK"  
  destination               = "0.0.0.0/0"  
  udp_options {
    destination_port_range {
      min = 6081
      max = 6081
    }       
  }  
}
resource "oci_core_network_security_group_security_rule" "tcp443_Out" {
  network_security_group_id = oci_core_network_security_group.ssh_icmp_tunnel_web.id
  description               = "tcp443_Out"
  direction                 = "EGRESS"
  protocol                  = 6
  destination_type          = "CIDR_BLOCK"  
  destination               = "0.0.0.0/0"  
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }  
}
resource "oci_core_network_security_group_security_rule" "tcp80_Out" {
  network_security_group_id = oci_core_network_security_group.ssh_icmp_tunnel_web.id
  description               = "tcp80_Out"
  direction                 = "EGRESS"
  protocol                  = 6
  destination_type          = "CIDR_BLOCK"  
  destination               = "0.0.0.0/0"    
  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }  
}
resource "oci_core_network_security_group_security_rule" "ssh_In" {
  network_security_group_id = oci_core_network_security_group.ssh_icmp_tunnel_web.id
  description               = "ssh_In"
  direction                 = "INGRESS"
  protocol                  = 6
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }  
}
resource "oci_core_network_security_group_security_rule" "icmp_In" {
  network_security_group_id = oci_core_network_security_group.ssh_icmp_tunnel_web.id
  description               = "icmp_In"
  direction                 = "INGRESS"
  protocol                  = 1
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
}
resource "oci_core_network_security_group_security_rule" "icmp_Out" {
  network_security_group_id = oci_core_network_security_group.ssh_icmp_tunnel_web.id
  description               = "icmp_Out"
  direction                 = "EGRESS"
  protocol                  = 1
  destination_type               = "CIDR_BLOCK"
  destination                    = "0.0.0.0/0"
}
resource "oci_core_instance" "layer2-oci-router" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "layer2-oci-router"
  shape               = "VM.Standard.E2.1"

  create_vnic_details {
    subnet_id        = oci_core_subnet.front-subnet.id
    display_name     = "Frontvnic"
    assign_public_ip = true
    nsg_ids = [
      oci_core_network_security_group.ssh_icmp_tunnel_web.id
    ]    
  }


  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.supported_shape_images.images[0]["id"]
    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs =	"60"
  }

  # Apply the following flag only if you wish to preserve the attached boot volume upon destroying this instance
  # Setting this and destroying the instance will result in a boot volume that should be managed outside of this config.
  # When changing this value, make sure to run 'terraform apply' so that it takes effect before the resource is destroyed.
  #preserve_boot_volume	=	true

  metadata = {
    ssh_authorized_keys = file(var.VM_SSH_PUBLICKEY_FILE)
  }

  freeform_tags = {
    project = "layer2project"
  }
  timeouts {
    create = "10m"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = oci_core_instance.layer2-oci-router.public_ip
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
      "sudo hostname layer2-oci-router",
    ]
  }  
  provisioner "file" {
    source      = "../common/tools.sh"
    destination = "/tmp/tools.sh"
    connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = oci_core_instance.layer2-oci-router.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = oci_core_instance.layer2-oci-router.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
    inline = [
      "chmod +x /tmp/tools.sh",
      "sudo bash -x /tmp/tools.sh",
      "sudo pkill -u ubuntu",
      "sudo deluser ubuntu",
      "sudo iptables -F",
    ]
  }     
}

resource "oci_core_instance" "layer2-oci-client1" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "layer2-oci-client1"
  shape               = "VM.Standard.E2.1"

  create_vnic_details {
    subnet_id        = oci_core_subnet.underlay-subnet.id
    display_name     = "client1_vnic"
    assign_public_ip = true
    nsg_ids = [
      oci_core_network_security_group.ssh_icmp_tunnel_web.id
    ]      
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.supported_shape_images.images[0]["id"]
    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs =	"60"
  }

  # Apply the following flag only if you wish to preserve the attached boot volume upon destroying this instance
  # Setting this and destroying the instance will result in a boot volume that should be managed outside of this config.
  # When changing this value, make sure to run 'terraform apply' so that it takes effect before the resource is destroyed.
  #preserve_boot_volume	=	true

  metadata = {
    ssh_authorized_keys = file(var.VM_SSH_PUBLICKEY_FILE)
  }

  freeform_tags = {
    project = "layer2project"
  }
  timeouts {
    create = "10m"
  }  
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = oci_core_instance.layer2-oci-client1.public_ip
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
      "sudo hostname layer2-oci-client1",
    ]
  }    
  provisioner "file" {
    source      = "../common/tools.sh"
    destination = "/tmp/tools.sh"
    connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = oci_core_instance.layer2-oci-client1.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = oci_core_instance.layer2-oci-client1.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
    }
    inline = [
      "chmod +x /tmp/tools.sh",
      "sudo bash -x /tmp/tools.sh",
      "sudo pkill -u ubuntu",
      "sudo deluser ubuntu",
      "sudo iptables -F",
    ]
  }  
}
resource "oci_core_vnic_attachment" "backend_vnic_attachment" {
  create_vnic_details {
    subnet_id        = oci_core_subnet.underlay-subnet.id
    display_name     = "backendvnic"
    assign_public_ip = false
    nsg_ids = [
      oci_core_network_security_group.ssh_icmp_tunnel_web.id
    ]      
  }
  instance_id = oci_core_instance.layer2-oci-router.id
}
resource "null_resource" "backend_interface_config" {
  depends_on = [oci_core_vnic_attachment.backend_vnic_attachment]
  connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = oci_core_instance.layer2-oci-router.public_ip
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "5m"
  }
  provisioner "file" {
    source      = "../common/interface.sh"
    destination = "/tmp/interface.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/interface.sh",
      "/tmp/interface.sh ${oci_core_vnic_attachment.backend_vnic_attachment.create_vnic_details[0].private_ip} ${var.UNDERLAY_SUBNETMASK}",
    ]
  } 
}

output "router_backend_ip" {
  value = oci_core_vnic_attachment.backend_vnic_attachment.create_vnic_details[0].private_ip
}
output "client1_ip" {
  value = oci_core_instance.layer2-oci-client1.private_ip
}
output "router_public_ip" {
  value = oci_core_instance.layer2-oci-router.public_ip
}
output "client1_public_ip" {
  value = oci_core_instance.layer2-oci-client1.public_ip
}

