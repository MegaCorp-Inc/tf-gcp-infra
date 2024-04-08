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

resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  crypto_key_id = var.kms_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}


resource "google_pubsub_topic_iam_binding" "binding" {
  project = var.project_id
  topic   = "verify-email"
  role    = "roles/pubsub.publisher"
  members = [
    "serviceAccount:${google_service_account.service_account.email}",
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
    source_image_encryption_key {
      kms_key_self_link = var.kms_key.name
    }
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

resource "random_id" "lb_id" {
  byte_length = 4
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "ssl-certificate-${random_id.lb_id.hex}"

  managed {
    domains = ["megamindcorp.me."]
  }
}

module "gce-lb-https" {
  source  = "terraform-google-modules/lb-http/google"
  version = "~> 10.0"
  name    = "lb-https-${random_id.lb_id.hex}"
  project = var.project_id
  target_tags = [
    "webapp-subnet"
  ]
  firewall_networks = [var.network]
  ssl               = true
  ssl_certificates  = [google_compute_managed_ssl_certificate.default.self_link]

  http_forward = false

  backends = {
    default = {

      protocol    = "HTTP"
      port_name   = "http"
      timeout_sec = 10
      enable_cdn  = false

      health_check = {
        request_path = "/healthz"
        port         = 6969
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group = google_compute_instance_group_manager.default.instance_group
        }
      ]

      iap_config = {
        enable = false
      }
    }
  }
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
    module.gce-lb-https.external_ip
  ]
}

output "webapp_private_ip" {
  value = module.gce-lb-https.external_ip
}
