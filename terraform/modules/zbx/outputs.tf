output "pgsql_cluster_id" {
  value = yandex_mdb_postgresql_cluster.zbx-db-cluster.id
}

output "zbx_server_fqdn" {
  value = yandex_compute_instance.zbx-srv.fqdn
}

output "zbx_db_password" {
  value = yandex_mdb_postgresql_user.zbx-db-user.password
}
