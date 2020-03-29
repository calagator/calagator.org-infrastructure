variable "do_token" {
  type = string
}

variable "ssh_keys" {
  type = map(string)
}

variable "ssh_provisioner_private_key" {
  type = string
}

output "public_ip" {
  value = digitalocean_floating_ip.calagator_org.ip_address
}

terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "calagator"

    workspaces {
      name = "calagator-org-infrastructure"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "keys" {
  for_each = var.ssh_keys
  name = each.key
  public_key = each.value
}

resource "digitalocean_droplet" "epoch" {
  name = "epoch"
  region = "sfo2"
  size = "s-2vcpu-4gb"
  image = "dokku-18-04"
  backups = true
  monitoring = true
  ipv6 = true
  ssh_keys = values(digitalocean_ssh_key.keys)[*].id
}

resource "digitalocean_floating_ip" "calagator_org" {
  droplet_id = digitalocean_droplet.epoch.id
  region = digitalocean_droplet.epoch.region
}
