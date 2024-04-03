terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
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
  route_table_id = yandex_vpc_route_table.rt-1.id
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "diplom-subnet2"
  zone           = var.zone2
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.rt-1.id
}

resource "yandex_vpc_gateway" "nat-gateway-1" {
  folder_id = var.folder_id
  name      = "diplom-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt-1" {
  folder_id  = var.folder_id
  name       = "diplom-route-table"
  network_id = yandex_vpc_network.network-1.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat-gateway-1.id
  }
}
