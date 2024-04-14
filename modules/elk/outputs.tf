output "elk_elasticsearch_fqdn" {
  value = yandex_compute_instance.elk-el.fqdn
}

output "elk_kibana_fqdn" {
  value = yandex_compute_instance.elk-kib.fqdn
}

output "elk_disk_ids" {
  value = [
    yandex_compute_instance.elk-el.boot_disk.0.disk_id,
    yandex_compute_instance.elk-kib.boot_disk.0.disk_id,
    yandex_compute_instance.elk-log.boot_disk.0.disk_id
  ]
}

output "elk_kibana_external_ip" {
  value = yandex_compute_instance.elk-kib.network_interface.0.nat_ip_address
}
