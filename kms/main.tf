resource "random_id" "keyring_id" {
  byte_length = 4
}

resource "google_kms_key_ring" "keyring" {
  name     = "keyring-webapp-${random_id.keyring_id.hex}"
  location = "global"
}

resource "google_kms_crypto_key" "cloudsql-crypto-key" {
  name            = "crypto-key-cloudsql-${random_id.keyring_id.hex}"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "2592000s"
}

resource "google_kms_crypto_key" "webapp-crypto-key" {
  name            = "crypto-key-webapp-${random_id.keyring_id.hex}"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "2592000s"
}

resource "google_kms_crypto_key" "bucket-crypto-key" {
  name            = "crypto-key-bucket-${random_id.keyring_id.hex}"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "2592000s"
}

resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  provider = google-beta
  service  = "sqladmin.googleapis.com"
  project  = var.project_id
}

resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  crypto_key_id = google_kms_crypto_key.cloudsql-crypto-key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}"
  ]
}

output "crypto_key_ring" {
  value = google_kms_key_ring.keyring
}

output "cloudsql_crypto_key" {
  value = google_kms_crypto_key.cloudsql-crypto-key
}
output "vm_crypto_key" {
  value = google_kms_crypto_key.webapp-crypto-key
}
output "bucket_crypto_key" {
  value = google_kms_crypto_key.bucket-crypto-key
}
