resource "random_id" "instance_id" {
  byte_length = 4
}

resource "google_service_account" "service_account" {
  account_id   = "webapp-sa-logger"
  display_name = "webapp logger SA"
}

resource "google_project_iam_binding" "logging-admin" {
  project = var.project_id
  role    = "roles/logging.admin"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

resource "google_project_iam_binding" "monitoring-metric-writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

resource "google_compute_instance" "webapp-instance" {
  name         = "webapp-instance-${random_id.instance_id.hex}"
  zone         = var.zone
  machine_type = "e2-medium"

  service_account {
    scopes = ["cloud-platform"]
    email  = google_service_account.service_account.email
  }

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

# fetching already created DNS zone
data "google_dns_managed_zone" "env_dns_zone" {
  name = "megacorp-domain"
}

# to register web-server's ip address in DNS
resource "google_dns_record_set" "default" {
  name         = data.google_dns_managed_zone.env_dns_zone.dns_name
  managed_zone = data.google_dns_managed_zone.env_dns_zone.name
  type         = "A"
  ttl          = 300
  rrdatas = [
    google_compute_instance.webapp-instance.network_interface[0].access_config[0].nat_ip
  ]
}
