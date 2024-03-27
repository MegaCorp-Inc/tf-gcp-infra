resource "google_compute_subnetwork" "db_subnet" {
  name                     = "${var.db_name}-subnetwork"
  ip_cidr_range            = var.ip_cidr_range_db
  region                   = var.region
  network                  = var.vpc_network_id
  private_ip_google_access = true
}

output "db_subnet" {
  value = google_compute_subnetwork.db_subnet
}
