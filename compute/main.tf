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

resource "google_project_iam_binding" "pubsub-publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"

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
    google_compute_instance.webapp-instance.network_interface.0.network_ip
  ]
}

resource "google_compute_instance_template" "lb-instance-template" {
  name         = "webapp-instance-${random_id.instance_id.hex}"
  machine_type = "e2-medium"

  service_account {
    scopes = ["cloud-platform"]
    email  = google_service_account.service_account.email
  }

  disk {
    source_image = "projects/${var.project_id}/global/images/${var.image_name}"
    disk_size_gb = 100
    disk_type    = "pd-balanced"
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet
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


resource "google_compute_health_check" "http-health-check" {
  name = "http-health-check-${random_id.manager_id.hex}"

  timeout_sec         = 10
  check_interval_sec  = 30
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port         = "6969"
    request_path = "/healthz"
  }
}

resource "google_compute_autoscaler" "default" {
  name   = "webapp-autoscaler-${random_id.manager_id.hex}"
  target = google_compute_instance_group_manager.default.id
  zone   = var.zone

  autoscaling_policy {
    max_replicas    = 2
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.05
    }
  }
}

resource "random_id" "manager_id" {
  byte_length = 4
}

resource "google_compute_instance_group_manager" "default" {
  name               = "webapp-instance-group-manager-${random_id.manager_id.hex}"
  base_instance_name = "webapp-instance"
  zone               = var.zone

  depends_on = [
    google_compute_instance_template.lb-instance-template
  ]

  version {
    instance_template = google_compute_instance_template.lb-instance-template.self_link
  }

  named_port {
    name = "http"
    port = 6969
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.http-health-check.id
    initial_delay_sec = 30
  }
}

output "webapp_private_ip" {
  value = google_compute_instance.webapp-instance.network_interface.0.network_ip
}
