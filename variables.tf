variable "project_id" {
  type        = string
  description = "Project ID"
  default     = "megamindcorp-dev"
}

variable "region" {
  type        = string
  description = "Region of the infrastructure"
  default     = "us-east1"
}

variable "zone" {
  type        = string
  description = "Zone of the infrastructure"
  default     = "us-east1-b"
}

variable "vpc_name" {
  type        = string
  description = "Name of the infrastructure"
  default     = "megacorp"
}

variable "vpc_type" {
  type        = string
  description = "Type of the VPC"
  default     = "REGIONAL"
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
  default     = "10.0.1.0/24"
}

variable "ip_cidr_range_db" {
  type        = string
  description = "List of The range of internal addresses that are owned by this subnetwork."
  default     = "10.0.2.0/24"
}

variable "dest_range" {
  type        = string
  description = "Destination range of the route"
  default     = "0.0.0.0/0"
}

variable "image_name" {
  type        = string
  description = "The image path for the instance"
  default     = "webapp-centos-stream-8-a4-v1-20240326205933"
}

variable "ports" {
  type        = list(string)
  description = "The ports to open"
  default     = ["6969","22"]
}

variable "machine_type" {
  type        = string
  description = "The machine type"
  default     = "e2-medium"
}

variable "tier" {
  type        = string
  description = "The tier of the database"
  default     = "db-g1-small"
}

variable "availability_type" {
  type        = string
  description = "The availability type of the database"
  default     = "REGIONAL"
}

variable "disk_type" {
  type        = string
  description = "The disk type"
  default     = "pd-balanced"
}
