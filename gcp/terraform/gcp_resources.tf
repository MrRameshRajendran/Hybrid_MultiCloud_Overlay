variable "GCP_KEY_FILE" {
  type    = string
  default = "~/.ssh/gcp-key.json"
}

variable "GCP_UNDERLAY_SUBNET" {
  type    = string
  default = "192.168.1.0/24"
}

variable "UNDERLAY_SUBNETMASK" {
  type    = string
  default = "255.255.255.0"
}
variable "GCP_FRONT_SUBNET" {
  type    = string
  default = "10.1.1.0/24"
}

variable "GCP_PROJECT" {
  type    = string
  default = "round-vent-223215"
}

variable "GCP_REGION" {
  type    = string
  default = "europe-west2"
}

variable "GCP_ZONE" {
  type    = string
  default = "europe-west2-a"
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

provider "google" {
  credentials = file(var.GCP_KEY_FILE)
  project     = var.GCP_PROJECT
  region      = var.GCP_REGION
}

data "google_compute_image" "ubuntu" {
  family  = "ubuntu-minimal-1804-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_network" "underlay-network" {
  name                    = "underlay-network"
  description             = "Back end network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "underlay-subnet" {
  name                     = "underlay-subnetwork"
  ip_cidr_range            = var.GCP_UNDERLAY_SUBNET
  network                  = google_compute_network.underlay-network.self_link
  private_ip_google_access = true
  region                   = var.GCP_REGION
}

resource "google_compute_network" "front-network" {
  name                    = "front-network"
  description             = "Front network, connects to Internet"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "front-subnet" {
  name                     = "front-subnetwork"
  ip_cidr_range            = var.GCP_FRONT_SUBNET
  network                  = google_compute_network.front-network.self_link
  private_ip_google_access = true
  region                   = var.GCP_REGION
}

resource "google_compute_firewall" "internal-icmp-ssh-tunnel" {
  name    = "internal-icmp-ssh-tunnel"
  network = google_compute_network.underlay-network.self_link
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  allow {
    protocol = "udp"
    ports    = ["4789", "8472", "6081"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["internal-icmp-ssh-tunnel"]
}

resource "google_compute_firewall" "external-ssh-tunnel" {
  name    = "external-ssh-tunnel"
  network = google_compute_network.front-network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  allow {
    protocol = "udp"
    ports    = ["4789", "8472", "6081"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["external-ssh-tunnel"]
}

resource "google_compute_address" "client1_publicip" {
  name = "client1-public-address"
}

resource "google_compute_address" "router_publicip" {
  name = "router-public-address"
}

resource "google_compute_address" "client1" {
  name         = "client1-ip"
  subnetwork   = google_compute_subnetwork.underlay-subnet.name
  address_type = "INTERNAL"
}

resource "google_compute_address" "router_backend" {
  name         = "router-backend-ip"
  subnetwork   = google_compute_subnetwork.underlay-subnet.name
  address_type = "INTERNAL"
}

resource "google_compute_instance" "layer2-gcp-client1" {
  name         = "layer2-gcp-client1"
  machine_type = "f1-micro"
  zone         = var.GCP_ZONE
  tags         = ["l2-project", "internal-icmp-ssh-tunnel"]
  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
    }
  }
  depends_on = [
    google_compute_firewall.internal-icmp-ssh-tunnel,
    google_compute_address.client1,
    google_compute_address.client1_publicip,
  ]
  metadata = {
    ssh-keys = "${var.VM_USER}:${file(var.VM_SSH_PUBLICKEY_FILE)}"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.underlay-subnet.name
    network_ip = google_compute_address.client1.address
    access_config {
      nat_ip = google_compute_address.client1_publicip.address
    }
  }

  provisioner "file" {
    source      = "../common/tools.sh"
    destination = "/tmp/tools.sh"
    connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = google_compute_address.client1_publicip.address
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "6m"
    }
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = google_compute_address.client1_publicip.address
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "6m"
    }
    inline = [
      "chmod +x /tmp/tools.sh",
      "sudo echo '${var.VM_USER} ALL=(ALL) NOPASSWD: ALL' > ${var.VM_USER}",
      "sudo mv ${var.VM_USER} /etc/sudoers.d/",
      "sudo chown -R 0:0 /etc/sudoers.d/${var.VM_USER}",
      "sudo /tmp/tools.sh",
    ]
  }
}

resource "google_compute_instance" "layer2-gcp-router" {
  name         = "layer2-gcp-router"
  machine_type = "f1-micro"
  zone         = var.GCP_ZONE
  tags         = ["l2-project", "external-ssh-tunnel", "internal-icmp-ssh-tunnel"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
    }
  }
  metadata = {
    ssh-keys = "${var.VM_USER}:${file(var.VM_SSH_PUBLICKEY_FILE)}"
  }
  depends_on = [
    google_compute_firewall.internal-icmp-ssh-tunnel,
    google_compute_firewall.external-ssh-tunnel,
    google_compute_address.router_backend,
    google_compute_address.router_publicip,
  ]
  network_interface {
    subnetwork = google_compute_subnetwork.front-subnet.name
    access_config {
      nat_ip = google_compute_address.router_publicip.address
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.underlay-subnet.name
    network_ip = google_compute_address.router_backend.address
  }
  provisioner "file" {
    source      = "../common/tools.sh"
    destination = "/tmp/tools.sh"
    connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = google_compute_address.router_publicip.address
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "6m"
    }
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.VM_USER
      host        = google_compute_address.router_publicip.address
      private_key = file(var.VM_SSH_KEY_FILE)
      timeout     = "6m"
    }
    inline = [
      "chmod +x /tmp/tools.sh",
      "sudo echo '${var.VM_USER} ALL=(ALL) NOPASSWD: ALL' > ${var.VM_USER}",
      "sudo mv ${var.VM_USER} /etc/sudoers.d/",
      "sudo chown -R 0:0 /etc/sudoers.d/${var.VM_USER}",
      "sudo /tmp/tools.sh",
    ]
  }
}
output "router_backend_ip" {
  value = google_compute_address.router_backend.address
}
output "client1_ip" {
  value = google_compute_address.client1.address
}
output "router_public_ip" {
  value = google_compute_address.router_publicip.address
}
output "client1_public_ip" {
  value = google_compute_address.client1_publicip.address
}

