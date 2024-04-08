resource "google_service_account" "account" {
  account_id   = "verify-email-sa"
  display_name = "CF Service Account"
}

resource "google_project_iam_binding" "function_deployer" {
  project = var.project_id
  role    = "roles/cloudfunctions.developer"

  members = [
    "serviceAccount:${google_service_account.account.email}",
  ]
}

resource "google_project_iam_binding" "token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"

  members = [
    "serviceAccount:${google_service_account.account.email}",
  ]
}

resource "google_project_iam_binding" "cloudsql_admin" {
  project = var.project_id
  role    = "roles/cloudsql.admin"

  members = [
    "serviceAccount:${google_service_account.account.email}",
  ]
}

# resource "google_kms_crypto_key_iam_binding" "crypto_key" {
#   crypto_key_id = var.kms_key.id
#   role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

#   members = [
#     "serviceAccount:${google_service_account.account.email}",
#   ]
# }

resource "random_id" "default" {
  byte_length = 8
}


resource "google_pubsub_topic" "topic" {
  name = "verify-email"
}


resource "google_pubsub_subscription" "subscription" {
  name  = "verify-email-subscription"
  topic = google_pubsub_topic.topic.name
}

resource "google_storage_bucket" "bucket" {
  depends_on                  = [var.kms_key]
  name                        = "${var.project_id}-source-${random_id.default.hex}" # Every bucket name must be globally unique
  location                    = "US"
  uniform_bucket_level_access = true
  # encryption {
  #   default_kms_key_name = var.kms_key.name
  # }
}

resource "google_storage_bucket_object" "object" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.bucket.name
  source = "/Users/piyushdongre/Desktop/cloud/tf-gcp-infra/cloudfunction/serverless.zip" # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "function" {
  name        = "send-verify-email"
  location    = "us-east1"
  description = "Send verification email"


  build_config {
    runtime     = "nodejs20"
    entry_point = "verifyEmailPubsub" # Set the entry point 
    environment_variables = {
      CHECK_ENV = "BUILD"
    }
    source {

      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.object.name
      }
    }
  }

  service_config {
    max_instance_count               = 1
    min_instance_count               = 0
    available_memory                 = "256M"
    timeout_seconds                  = 60
    max_instance_request_concurrency = 10
    available_cpu                    = "1"
    environment_variables = {
      CHECK_ENV           = "SERVICE"
      API_KEY             = "05890ef4341d57376fb162f7e452fab5-309b0ef4-9f2bdf3b"
      DOMAIN              = "mg.megamindcorp.me"
      VERIFY_URL          = "https://megamindcorp.me/v1/user/verify/"
      POSTGRESQL_DB       = var.db_name
      POSTGRESQL_USER     = var.db_user
      POSTGRESQL_PASSWORD = var.db_password
      POSTGRESQL_HOST     = var.private_ip
    }
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.account.email
    vpc_connector                  = google_vpc_access_connector.cloud_function.id
    vpc_connector_egress_settings  = "PRIVATE_RANGES_ONLY"
  }

  event_trigger {
    trigger_region = "us-east1"
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.topic.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }
}

resource "google_vpc_access_connector" "cloud_function" {
  name          = "cloud-run-vpc-connector"
  ip_cidr_range = "10.8.0.0/28"
  network       = var.vpc_network_id
}
