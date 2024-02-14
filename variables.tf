variable "project_id" {
  type        = string
  description = "Project ID"
  default     = "megamindcorp"
}

variable "region" {
  type        = string
  description = "Region of the infrastructure"
  default     = "us-east1"
}

variable "vpc_name" {
  type        = string
  description = "Name of the infrastructure"
  default     = "megacorp"
}

variable "webapp_name" {
  type        = string
  description = "Name of the webapp"
  default     = "webapp"
}

variable "db_name" {
  type        = string
  description = "Name of the database"
  default     = "db"
}

variable "ip_cidr_range_webapp" {
  type        = string
  description = "List of The range of internal addresses that are owned by this subnetwork."
  default     = "69.4.20.0/24"
}

variable "ip_cidr_range_db" {
  type        = string
  description = "List of The range of internal addresses that are owned by this subnetwork."
  default     = "4.20.69.0/24"
}

variable "dest_range" {
  type        = string
  description = "Destination range of the route"
  default     = "0.0.0.0/0"
}
