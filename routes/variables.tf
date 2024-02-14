variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "dest_range" {
  type        = string
  description = "Destination range of the route"
}

variable "vpc_network_id" {
  type        = string
  description = "The VPC network to host the subnet in."
}
