variable "resource_group_name" {
  type    = string
  default = "demo-task-rg"
}

variable "location" {
  type    = string
  default = "uksouth"
}


variable "mysql_flexible_server_name" {
  type    = list(string)
  default = ["demo-task-mysql-flexible-server"]
}


variable "db_administrator_login" {
  type    = string
  default = "psqladmin"
}

variable "db_administrator_password" {
  type    = string
  default = "H@Sh1CoR3!"
}
variable "mysql_database_name" {
  type    = string
  default = "demo_task_database"
}

variable "allowed_public_ip" {
  type    = list(string)
  default = ["92.7.185.142"]
}

variable "db_source_address" {
  description = "The source address for the network security rule"
  default     = "92.7.185.142"
}
variable "vm_vnet" {
  type    = string
  default = "demo-task-vm-vnet"
}
variable "vm_vnet_address_space" {
  type    = list(string)
  default = ["10.50.0.0/16"]
}

variable "firewall_public_ip" {
  type    = string
  default = "20.108.168.251"
}

variable "demo_task_vm_names" {
  type    = list(string)
  default = ["demotaskvm"]
}
