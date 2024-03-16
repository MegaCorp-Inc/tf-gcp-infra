resource "google_compute_firewall" "rules" {
  project     = var.project_id
  name        = "allow-webapp-ports"
  network     = var.network
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol = "tcp"
    ports    = var.ports
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["webapp-subnet"]
}

resource "google_compute_firewall" "deny_all_egress" {
  project     = var.project_id
  name        = "deny-all-egress"
  network     = var.network
  description = "Deny all egress traffic"

  deny {
    protocol = "all"
  }

  source_ranges = ["4.20.69.0/24"]

}

resource "google_compute_firewall" "allow_egress_to_vm" {
  project = var.project_id
  name    = "allow-egress-to-vm"
  network = var.network

  allow {
    protocol = "tcp"
  }

  source_ranges = ["4.20.69.0/24"]
  target_tags   = ["webapp-subnet"]
}
