terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

resource "yandex_mdb_opensearch_cluster" "foo" {
  name        = "diplom-cluster"
  environment = "PRODUCTION"
  network_id  = var.vpc.network_1_id

  config {

    admin_password = "super-password"

    opensearch {
      node_groups {
        name             = "hot_group0"
        assign_public_ip = true
        hosts_count      = 2
        zone_ids         = local.zones
        roles            = ["data"]
        resources {
          resource_preset_id = "s2.small"
          disk_size          = 10737418240
          disk_type_id       = "network-ssd"
        }
      }

      node_groups {
        name             = "cold_group0"
        assign_public_ip = true
        hosts_count      = 2
        zone_ids         = local.zones
        roles            = ["data"]
        resources {
          resource_preset_id = "s2.micro"
          disk_size          = 10737418240
          disk_type_id       = "network-hdd"
        }
      }

      node_groups {
        name             = "managers_group"
        assign_public_ip = true
        hosts_count      = 3
        zone_ids         = local.zones
        roles            = ["manager"]
        resources {
          resource_preset_id = "s2.micro"
          disk_size          = 10737418240
          disk_type_id       = "network-ssd"
        }
      }

      plugins = ["analysis-icu"]
    }

    dashboards {
      node_groups {
        name             = "dashboards"
        assign_public_ip = true
        hosts_count      = 1
        zone_ids         = local.zones
        resources {
          resource_preset_id = "s2.micro"
          disk_size          = 10737418240
          disk_type_id       = "network-ssd"
        }
      }
    }
  }

  depends_on = [
    yandex_vpc_subnet.es-subnet-a,
    yandex_vpc_subnet.es-subnet-b,
    yandex_vpc_subnet.es-subnet-c,
  ]

}

resource "yandex_vpc_network" "es-net" {}

resource "yandex_vpc_subnet" "es-subnet-a" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.es-net.id
  v4_cidr_blocks = ["10.1.0.0/24"]
}

resource "yandex_vpc_subnet" "es-subnet-b" {
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.es-net.id
  v4_cidr_blocks = ["10.2.0.0/24"]
}

resource "yandex_vpc_subnet" "es-subnet-c" {
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.es-net.id
  v4_cidr_blocks = ["10.3.0.0/24"]
}
