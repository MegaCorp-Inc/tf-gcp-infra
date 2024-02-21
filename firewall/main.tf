resource "google_compute_firewall" "rules" {
  project     = var.project_id 
  name        = "allow-webapp-ports"
  network     = var.network
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol  = "tcp"
    ports     = var.ports
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["webapp-subnet"]
}
