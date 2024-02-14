resource "google_compute_subnetwork" "webapp_subnet" {
  name                     = "${var.webapp_name}-subnetwork"
  ip_cidr_range            = var.ip_cidr_range_webapp
  region                   = var.region
  network                  = var.vpc_network_id
  private_ip_google_access = true
}
