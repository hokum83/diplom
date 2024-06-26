output "network_1_id" {
  value = yandex_vpc_network.network-1.id
}

output "subnet_1_id" {
  value = yandex_vpc_subnet.subnet-1.id
}

output "subnet_2_id" {
  value = yandex_vpc_subnet.subnet-2.id
}

output "private_sg_id" {
  value = yandex_vpc_security_group.private-sg.id
}

output "public_sg_id" {
  value = yandex_vpc_security_group.public-sg.id
}
