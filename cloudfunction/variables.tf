variable "project_id" {
  description = "The project ID"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_password" {
  description = "Password of the database"
  type        = string
}

variable "db_user" {
  description = "User of the database"
  type        = string
}

variable "private_ip" {
  description = "Private IP of the database"
  type        = string
}

variable "vpc_network_id" {
  description = "The network ID"
  type        = string
}

variable "vm_ip" {
  description = "The IP of the VM"
  type        = string
}

variable "kms_key" {
  description = "The KMS key"
}

variable "region" {
  description = "The region"
  type        = string
}
