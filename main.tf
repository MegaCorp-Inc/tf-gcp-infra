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

# VPC
resource "google_compute_network" "this" {
  name                            = "${var.vpc_name}-vpc"
  delete_default_routes_on_create = true
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
}

# SUBNETS
resource "google_compute_subnetwork" "webapp_subnet" {
  name                     = "${var.webapp_name}-subnetwork"
  ip_cidr_range            = var.ip_cidr_range_webapp
  region                   = var.region
  network                  = google_compute_network.this.self_link
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "db_subnet" {
  name                     = "${var.db_name}-subnetwork"
  ip_cidr_range            = var.ip_cidr_range_db
  region                   = var.region
  network                  = google_compute_network.this.self_link
  private_ip_google_access = true
}

resource "google_compute_route" "webapp_default_route" {
  name             = "webapp-default-route"
  network          = google_compute_network.this.id
  dest_range       = var.dest_range
  next_hop_gateway = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/gateways/default-internet-gateway"
  priority         = 1000
  tags             = ["webapp-subnet"]
}
