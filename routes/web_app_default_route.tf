resource "google_compute_route" "webapp_default_route" {
  name             = "webapp-default-route"
  network          = var.vpc_network_id
  dest_range       = var.dest_range
  next_hop_gateway = "default-internet-gateway"
  tags             = ["webapp-subnet"]
}
