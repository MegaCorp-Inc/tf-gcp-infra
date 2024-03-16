resource "google_sql_database" "database" {
  name            = "webapp-1"
  instance        = google_sql_database_instance.this.name
  deletion_policy = "ABANDON"
}

resource "random_id" "this" {
  byte_length = 4
}

resource "google_sql_database_instance" "this" {
  name             = "megacorp-db-instance-db8fb074"
  database_version = "POSTGRES_15"
  settings {
    tier = var.tier
    ip_configuration {
      psc_config {
        psc_enabled               = true
        allowed_consumer_projects = [var.project_id]
      }
      ipv4_enabled = false
    }
    availability_type           = var.availability_type
    deletion_protection_enabled = false
  }
  deletion_protection = false
}

resource "google_compute_address" "default" {
  provider     = google
  project      = var.project_id
  name         = "local-psconnect-ip"
  address_type = "INTERNAL"
  subnetwork   = var.subnet
}
# [END compute_internal_ip_private_access]

# [START compute_forwarding_rule_private_access]
resource "google_compute_forwarding_rule" "default" {
  provider              = google
  project               = var.project_id
  name                  = "localrule"
  target                = google_sql_database_instance.this.psc_service_attachment_link
  network               = var.vpc_network_id
  ip_address            = google_compute_address.default.id
  load_balancing_scheme = ""
}

resource "random_password" "this" {
  length           = 10
  special          = true
  override_special = "@"
}

resource "google_sql_user" "user" {
  name       = "megamind"
  instance   = google_sql_database_instance.this.name
  password   = random_password.this.result
  depends_on = [google_sql_database_instance.this]
  deletion_policy = "ABANDON"
}


output "db_name" {
  value = google_sql_database.database.name
}

output "db_password" {
  value = random_password.this.result
}

output "db_user" {
  value = google_sql_user.user.name
}

output "host_ip" {
  value = google_compute_address.default.address
}
