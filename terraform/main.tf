terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone1
  service_account_key_file = var.key_file
}



###### VPC ######

resource "yandex_vpc_network" "network-1" {
  name = "diplom-network"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "diplom-subnet1"
  zone           = var.zone1
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "diplom-subnet2"
  zone           = var.zone2
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  folder_id = var.folder_id
  name      = "diplom-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  folder_id  = var.folder_id
  name       = "diplom-route-table"
  network_id = yandex_vpc_network.network-1.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

###### ALB ######

resource "yandex_alb_http_router" "http-router-1" {
  name = "diplom-http-router"
}

resource "yandex_alb_virtual_host" "virtual-host-1" {
  name           = "diplom-virtual-host"
  http_router_id = yandex_alb_http_router.http-router-1.id
  route {
    name = "diplom-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend-group-1.id
        timeout          = "3s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "load-balancer-1" {
  name       = "diplom-load-balancer"
  depends_on = [yandex_alb_http_router.http-router-1]
  network_id = yandex_vpc_network.network-1.id

  allocation_policy {
    location {
      zone_id   = var.zone1
      subnet_id = yandex_vpc_subnet.subnet-1.id
    }
    location {
      zone_id   = var.zone2
      subnet_id = yandex_vpc_subnet.subnet-2.id
    }
  }

  listener {
    name = "diplom-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.http-router-1.id
      }
    }
  }
}

resource "yandex_alb_backend_group" "backend-group-1" {
  name       = "diplom-backend-group"
  depends_on = [yandex_compute_instance_group.instance-group-1]
  http_backend {
    name             = "diplom-http-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_compute_instance_group.instance-group-1.application_load_balancer.0.target_group_id]
    load_balancing_config {
      panic_threshold = 50
    }
    healthcheck {
      timeout  = "1s"
      interval = "1s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_iam_service_account" "service-account-1" {
  name = "diplom-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.service-account-1.id}"
  depends_on = [
    yandex_iam_service_account.service-account-1,
  ]
}


###### COMPUTE ######

resource "yandex_compute_instance_group" "instance-group-1" {
  name                = "diplom-instance-group"
  folder_id           = var.folder_id
  service_account_id  = yandex_iam_service_account.service-account-1.id
  deletion_protection = false
  depends_on          = [yandex_resourcemanager_folder_iam_member.editor]
  instance_template {
    platform_id = "standard-v1"
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = var.image_id
      }
    }
    network_interface {
      network_id = yandex_vpc_network.network-1.id
      subnet_ids = ["${yandex_vpc_subnet.subnet-1.id}", "${yandex_vpc_subnet.subnet-2.id}"]
    }

    labels = {
      type = "web"
    }

    metadata = {
      user-data = "${file("./meta.txt")}"
    }
    network_settings {
      type = "STANDARD"
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    zones = [var.zone1, var.zone2]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }
  application_load_balancer {
    target_group_name = "target-group-1"
  }
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
    type = "zbx-srv"
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
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
    type = "zbx-fe"
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

}

resource "yandex_mdb_postgresql_cluster" "zbx-db-cluster" {
  name        = "zabbix-db"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.network-1.id

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
    subnet_id = yandex_vpc_subnet.subnet-1.id
  }

  host {
    zone      = var.zone2
    subnet_id = yandex_vpc_subnet.subnet-2.id
  }
}

resource "yandex_mdb_postgresql_database" "zbx-db" {
  cluster_id = yandex_mdb_postgresql_cluster.zbx-db-cluster.id
  name       = var.zbx-db-name
  owner      = yandex_mdb_postgresql_user.zbx-db-user.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
}

resource "yandex_mdb_postgresql_user" "zbx-db-user" {
  cluster_id = yandex_mdb_postgresql_cluster.zbx-db-cluster.id
  name       = var.zbx-db-user
  password   = var.zbx-db-password
}











resource "yandex_compute_instance" "jump" {
  name        = "jump-host"
  depends_on  = [yandex_compute_instance_group.instance-group-1]
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
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  provisioner "local-exec" {
    command = "ansible-playbook --ssh-common-args='-J user@${self.network_interface.0.nat_ip_address}' ./playbooks/web.yml"
  }

}

output "external_ip_address_jump" {
  value = yandex_compute_instance.jump.network_interface.0.nat_ip_address
}

