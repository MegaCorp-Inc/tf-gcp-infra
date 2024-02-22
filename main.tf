provider "google" {
  project = var.project_id
  region  = var.region
}

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
  vpc_type = var.vpc_type
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

module "compute" {
  source     = "./compute"
  project_id = var.project_id
  region     = var.region
  zone       = var.zone
  network    = module.vpc.vpc_network_id
  subnet     = module.subnet.subnet_id
  image_path = var.image_path
}

module "firewall" {
  source     = "./firewall"
  project_id = var.project_id
  network    = module.vpc.vpc_network_id
  ports      = var.ports
}
