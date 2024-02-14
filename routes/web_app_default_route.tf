resource "google_compute_route" "webapp_default_route" {
  name             = "webapp-default-route"
  network          = var.vpc_network_id
  dest_range       = var.dest_range
  next_hop_gateway = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/gateways/default-internet-gateway"
  priority         = 1000
  tags             = ["webapp-subnet"]
}
