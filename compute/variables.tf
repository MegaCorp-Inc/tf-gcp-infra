variable "project_id" {
  description = "The project ID"
  type        = string
}

variable "region" {
  description = "The region"
  type        = string
}

variable "zone" {
  description = "The zone"
  type        = string
}

variable "network" {
  description = "network ID"
  type        = string
}

variable "subnet" {
  description = "subnet ID"
  type        = string
}

variable "image_name" {
  description = "The image path for the instance"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_password"{
  description = "Password of the database"
  type        = string
}

variable "db_user"{
  description = "User of the database"
  type        = string
}

variable "private_ip"{
  description = "Private IP of the database"
  type        = string
}
