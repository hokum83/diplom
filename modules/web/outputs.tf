output "web_fqdn" {
  value = yandex_compute_instance_group.web-group-1.instances.*.fqdn
}

output "web_disk_ids" {
  value = flatten(data.yandex_compute_instance.web_instances[*].boot_disk.0.disk_id)
}

output "alb_external_ip" {
  value = yandex_alb_load_balancer.load-balancer-1.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}
