resource "google_compute_network" "this" {
  name                            = var.vpc_name
  delete_default_routes_on_create = true
  auto_create_subnetworks         = false
  routing_mode                    = var.vpc_type
}

output "vpc_network_id" {
  value = google_compute_network.this.id
}
