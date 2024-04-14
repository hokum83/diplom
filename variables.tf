variable "cloud_id" {
  description = "Cloud"
}
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

variable "key_file" {
  description = "Service Account Key File"
}

variable "zbx_db_name" {
}

variable "zbx_db_user" {
}
