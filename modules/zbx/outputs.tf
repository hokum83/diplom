output "pgsql_cluster_id" {
  value = yandex_mdb_postgresql_cluster.zbx-db-cluster.id
}

output "zbx_server_fqdn" {
  value = yandex_compute_instance.zbx-srv.fqdn
}
output "zbx_fe_external_ip" {
  value = yandex_compute_instance.zbx-fe.network_interface.0.nat_ip_address
}

output "zbx_db_password" {
  value = yandex_mdb_postgresql_user.zbx-db-user.password
}

output "zbx_disk_ids" {
  value = [
    yandex_compute_instance.zbx-srv.boot_disk.0.disk_id,
    yandex_compute_instance.zbx-fe.boot_disk.0.disk_id
  ]
}
