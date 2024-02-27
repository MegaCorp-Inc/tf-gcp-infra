resource "random_id" "instance_id" {
  byte_length = 4
}
resource "google_compute_instance" "webapp-instance" {
  name         = "webapp-instance-${random_id.instance_id.hex}"
  zone         = var.zone
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "projects/${var.project_id}/global/images/${var.image_name}"
      size  = 100
      type  = "pd-balanced"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet
    access_config {}
  }

  tags = ["webapp-subnet"]

  metadata_startup_script = <<-EOF
    touch .env
    echo POSTGRESQL_DB=${var.db_name} >> .env
    echo POSTGRESQL_USER=${var.db_user} >> .env
    echo POSTGRESQL_PASSWORD=${var.db_password} >> .env
    echo POSTGRESQL_HOST=${var.private_ip} >> .env
    echo PORT=6969 >> .env

    sudo mv .env /opt/webapp/.env
    EOF
}
