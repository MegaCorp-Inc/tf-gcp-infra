variable "tier" {
  description = "The tier of the database"
  type        = string
}

variable "availability_type" {
  description = "The availability type of the database"
  type        = string
}

variable "project_id" {
  description = "The project ID"
  type        = string
}

variable "region" {
  description = "The region"
  type        = string
}

variable "vpc_network_id" {
  description = "The network ID"
  type        = string
}

variable "subnet" {
  description = "The subnet"
  type        = string
}

variable "kms_key" {
  description = "The KMS key"
}
