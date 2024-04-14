terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

resource "yandex_compute_instance" "jump" {
  name        = "jump-host"
  zone        = var.zone1
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 2
  }
  labels = {
    type = "jump"
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id          = var.subnet_1_id
    nat                = true
    security_group_ids = [var.public_sg_id]
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  provisioner "local-exec" {
    command = "ansible-playbook --ssh-common-args='-o ProxyCommand=\"ssh -o StrictHostKeyChecking=no -W %h:%p -q user@${self.network_interface.0.nat_ip_address}\"' ./playbooks/playbooks.yml"
  }

}

