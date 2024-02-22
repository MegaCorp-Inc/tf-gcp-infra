variable "project_id" {
  description = "The project ID"
  type = string
}

variable "region" {
  description = "The region"
  type = string  
}

variable "zone" {
  description = "The zone"
  type = string  
}

variable "network" {
  description = "network ID"
  type = string  
}

variable "subnet" {
  description = "subnet ID"
  type = string  
}

variable "image_path" {
  description = "The image path for the instance"
  type = string
}
