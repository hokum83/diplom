output "instance_fqdn" {
  value = yandex_compute_instance_group.instance-group-1.instances.*.fqdn
}
