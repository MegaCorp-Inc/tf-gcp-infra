resource "google_sql_database" "database" {
  name            = "webapp-1"
  instance        = google_sql_database_instance.this.name
  deletion_policy = "ABANDON"
}

resource "random_id" "this" {
  byte_length = 4
}

resource "google_sql_database_instance" "this" {
  name             = "megacorp-db-instance-${random_id.this.hex}"
  database_version = "POSTGRES_15"
  depends_on       = [google_service_networking_connection.private_vpc_connection]
  region           = "us-east1"
  settings {
    tier                        = var.tier
    availability_type           = var.availability_type
    deletion_protection_enabled = false
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.vpc_network_id
      enable_private_path_for_google_cloud_services = true
    }
  }
  deletion_protection = false
}

resource "google_compute_global_address" "private_ip_address" {
  provider = google

  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_network_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google

  network                 = var.vpc_network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  deletion_policy         = "ABANDON"
}


# resource "google_compute_address" "default" {
#   provider     = google
#   project      = var.project_id
#   name         = "local-psconnect-ip"
#   address_type = "INTERNAL"
#   subnetwork   = var.subnet
# }
# # [END compute_internal_ip_private_access]

# # [START compute_forwarding_rule_private_access]
# resource "google_compute_forwarding_rule" "default" {
#   provider              = google
#   project               = var.project_id
#   name                  = "localrule"
#   target                = google_sql_database_instance.this.psc_service_attachment_link
#   network               = var.vpc_network_id
#   ip_address            = google_compute_address.default.id
#   load_balancing_scheme = ""
# }

resource "random_password" "this" {
  length           = 10
  special          = true
  override_special = "@"
}

resource "google_sql_user" "user" {
  name            = "megamind"
  instance        = google_sql_database_instance.this.name
  password        = random_password.this.result
  depends_on      = [google_sql_database_instance.this]
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
  value = google_sql_database_instance.this.private_ip_address
}
