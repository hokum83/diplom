terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

resource "yandex_compute_instance" "zbx-srv" {
  name        = "zabbix-server"
  zone        = var.zone1
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 2
  }
  labels = {
    type = "zbxsrv"
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


resource "yandex_compute_instance" "zbx-fe" {
  name        = "zabbix-frontend"
  zone        = var.zone1
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 2
  }
  labels = {
    type = "zbxfe"
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

resource "yandex_mdb_postgresql_cluster" "zbx-db-cluster" {
  name               = "diplom-pgsql-cluster"
  environment        = "PRESTABLE"
  network_id         = var.network_1_id
  security_group_ids = [var.private_sg_id]


  config {
    version = 15
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 10
    }
  }

  maintenance_window {
    type = "ANYTIME"
  }

  host {
    zone      = var.zone1
    subnet_id = var.subnet_1_id
  }

  host {
    zone      = var.zone2
    subnet_id = var.subnet_2_id

  }
}

resource "yandex_mdb_postgresql_database" "zbx-db" {
  cluster_id = yandex_mdb_postgresql_cluster.zbx-db-cluster.id
  name       = var.zbx_db_name
  owner      = yandex_mdb_postgresql_user.zbx-db-user.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
}

resource "yandex_mdb_postgresql_user" "zbx-db-user" {
  cluster_id = yandex_mdb_postgresql_cluster.zbx-db-cluster.id
  name       = var.zbx_db_user
  password   = random_password.password.result
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$&-_?"
  lifecycle {
    ignore_changes = [
      length,
      special,
      override_special
    ]
  }
}
