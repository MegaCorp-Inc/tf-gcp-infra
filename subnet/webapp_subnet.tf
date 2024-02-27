resource "google_compute_subnetwork" "webapp_subnet" {
  name                     = "${var.webapp_name}-subnetwork"
  ip_cidr_range            = var.ip_cidr_range_webapp
  region                   = var.region
  network                  = var.vpc_network_id
}

output "webapp_subnet" {
  value = google_compute_subnetwork.webapp_subnet.id
}
