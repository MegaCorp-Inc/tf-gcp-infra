variable "region" {
  type = string
}

variable "webapp_name" {
  type        = string
  description = "Name of the webapp"
}

variable "db_name" {
  type        = string
  description = "Name of the database"
}

variable "ip_cidr_range_webapp" {
  type        = string
  description = "List of The range of internal addresses that are owned by this subnetwork."
}

variable "ip_cidr_range_db" {
  type        = string
  description = "List of The range of internal addresses that are owned by this subnetwork."
}

variable "vpc_network_id" {
  type        = string
  description = "The VPC network to host the subnet in."
}
