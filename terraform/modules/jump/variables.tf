variable "folder_id" {
  description = "Folder"
}
variable "zone1" {
  description = "Zone"
  default     = "ru-central1-a"
}
variable "zone2" {
  description = "Zone"
  default     = "ru-central1-b"
}
variable "image_id" {
  description = "Disk image"
}

variable "network_1_id" {
  description = "network_1_id"
}

variable "subnet_1_id" {
  description = "subnet_1_id"
}

variable "subnet_2_id" {
  description = "subnet_2_id"
}

variable "instance_fqdn" {
  description = "instance_fqdn"
}

variable "pgsql_cluster_id" {
  description = "pgsql_instance_id"
}
