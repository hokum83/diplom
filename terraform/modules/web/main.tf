terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

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
  network_id = var.network_1_id

  allocation_policy {
    location {
      zone_id   = var.zone1
      subnet_id = var.subnet_1_id
    }
    location {
      zone_id   = var.zone2
      subnet_id = var.subnet_2_id
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
      network_id = var.network_1_id
      subnet_ids = ["${var.subnet_1_id}", "${var.subnet_2_id}"]
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

