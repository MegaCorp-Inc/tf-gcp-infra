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

module "sql_db" {
  source            = "./sql_db"
  project_id        = var.project_id
  region            = var.region
  tier              = var.tier
  availability_type = var.availability_type
  vpc_network_id    = module.vpc.vpc_network_id
  subnet            = module.subnet.db_subnet.id
}

module "compute" {
  source      = "./compute"
  project_id  = var.project_id
  region      = var.region
  zone        = var.zone
  network     = module.vpc.vpc_network_id
  subnet      = module.subnet.webapp_subnet
  image_name  = var.image_name
  db_name     = module.sql_db.db_name
  db_user     = module.sql_db.db_user
  db_password = module.sql_db.db_password
  private_ip  = module.sql_db.host_ip
}

module "cloudfunction" {
  source         = "./cloudfunction"
  project_id     = var.project_id
  db_name        = module.sql_db.db_name
  db_user        = module.sql_db.db_user
  db_password    = module.sql_db.db_password
  private_ip     = module.sql_db.host_ip
  vpc_network_id = module.vpc.vpc_network_id
  vm_ip          = module.compute.webapp_private_ip
}

module "firewall" {
  source     = "./firewall"
  project_id = var.project_id
  network    = module.vpc.vpc_network_id
  ports      = var.ports
}
