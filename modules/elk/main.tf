terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

resource "yandex_compute_instance" "elk-kib" {
  name        = "elk-kibana"
  zone        = var.zone1
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 2
  }
  labels = {
    type = "kibana"
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

}

resource "yandex_compute_instance" "elk-log" {
  name        = "elk-logstash"
  zone        = var.zone1
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 2
  }
  labels = {
    type = "logstash"
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id          = var.subnet_1_id
    security_group_ids = [var.private_sg_id]
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

}


resource "yandex_compute_instance" "elk-el" {
  name        = "elk-elastic"
  zone        = var.zone1
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 4
  }
  labels = {
    type = "elasticsearch"
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id          = var.subnet_1_id
    security_group_ids = [var.private_sg_id]
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

}
