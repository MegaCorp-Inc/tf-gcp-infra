provider "google" {
  project = var.project_id
  region  = 

data "google_compute_zones" "this" {
  region  = var.region
  project = var.project_id
}

locals {
  type  = ["public", "private"]
  zones = data.google_compute_zones.this.names
}

module "vpc" {
  source   = "./vpc"
  vpc_name = var.vpc_name
}

module "subnet" {
  source               = "./subnet"
  webapp_name          = var.webapp_name
  db_name              = var.db_name
  ip_cidr_range_webapp = var.ip_cidr_range_webapp
  ip_cidr_range_db     = var.ip_cidr_range_db
  region               = var.region
  vpc_network_id       = module.vpc.vpc_network_id
}

module "routes" {
  source         = "./routes"
  project_id     = var.project_id
  dest_range     = var.dest_range
  vpc_network_id = module.vpc.vpc_network_id
}
