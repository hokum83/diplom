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

resource "yandex_vpc_security_group" "private-sg" {
  name       = "Private Security Group"
  network_id = yandex_vpc_network.network-1.id
  depends_on = [yandex_vpc_security_group.public-sg]

  ingress {
    protocol          = "TCP"
    description       = "elasticsearch"
    security_group_id = yandex_vpc_security_group.public-sg.id
    port              = 9200
  }

  ingress {
    protocol          = "TCP"
    description       = "zabbix server"
    security_group_id = yandex_vpc_security_group.public-sg.id
    port              = 10051
  }

  ingress {
    protocol          = "TCP"
    description       = "nginx"
    security_group_id = yandex_vpc_security_group.public-sg.id
    port              = 80
  }

  ingress {
    protocol          = "TCP"
    description       = "SSH"
    security_group_id = yandex_vpc_security_group.public-sg.id
    port              = 22
  }

  ingress {
    protocol          = "TCP"
    description       = "logstash"
    security_group_id = yandex_vpc_security_group.public-sg.id
    port              = 5044
  }

  ingress {
    protocol          = "TCP"
    description       = "posgresql"
    security_group_id = yandex_vpc_security_group.public-sg.id
    port              = 6432
  }

  ingress {
    protocol          = "ANY"
    description       = "internal"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  egress {
    protocol       = "ANY"
    description    = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "public-sg" {
  name       = "Public Security Group"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    description    = "kibana"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  ingress {
    protocol       = "TCP"
    description    = "zabbix frontend & alb"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "zabbix agent"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24"]
    port           = 10050
  }

  ingress {
    protocol          = "TCP"
    description       = "Health checks from NLB"
    predefined_target = "loadbalancer_healthchecks"
    port              = 30080
  }

  ingress {
    protocol          = "ANY"
    description       = "internal"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  egress {
    protocol       = "ANY"
    description    = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
