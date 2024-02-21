resource "google_compute_instance" "webapp-instance" {
  name         = "webapp-instance-${lower(replace(timestamp(), ":", "-"))}"
  zone         = var.zone
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = var.image_path
    }
  }

  network_interface {
    network = var.network
    subnetwork = var.subnet
    access_config {}
  }

  tags = ["webapp-subnet"]
}
