output "external_ip_address_jump" {
  value = yandex_compute_instance.jump.network_interface.0.nat_ip_address
}

output "jump_disk_id" {
  value = yandex_compute_instance.jump.boot_disk.0.disk_id
}
