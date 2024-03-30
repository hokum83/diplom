variable "cloud_id" {
  description = "Cloud"
}
variable "folder_id" {
  description = "Folder"
}
variable "zone" {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
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
variable "icount" {
  default     = 1
  description = "VMs count"
}
