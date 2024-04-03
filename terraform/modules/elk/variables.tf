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
variable "ssh_private_key" {
  description = "Private key for ansible connection"
}
variable "user" {
  description = "User for ansible connection"
}
variable "key_file" {
  description = "Service Account Key File"
}

variable "zbx-db-name" {
}

variable "zbx-db-user" {
}

variable "zbx-db-password" {
}
