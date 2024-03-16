variable "project_id" {
  description = "The project ID"
  type        = string
}

variable "network" {
  description = "The VPC network"
  type        = string
}

variable "ports" {
  description = "The ports to open"
  type        = list(string)
}
