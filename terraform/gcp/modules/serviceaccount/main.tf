provider "google" {
  project     = var.project_id
  region      = var.location
  credentials = file("key.json")
}

# Create sunbird-serviceaccount service account
resource "google_service_account" "sunbird_serviceaccount" {
  account_id   = "sunbird-serviceaccount"
  display_name = "Sunbird Service Account"
  description  = "Service account for managing Sunbird resources"
}

#  Owner role to the service account
resource "google_project_iam_member" "sunbird_serviceaccount_owner" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.sunbird_serviceaccount.email}"
}

#  key for the service account
resource "google_service_account_key" "sunbird_serviceaccount_key" {
  service_account_id = google_service_account.sunbird_serviceaccount.name
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

#  service account key to a local file
resource "local_file" "service_account_key_file" {
  content  = google_service_account_key.sunbird_serviceaccount_key.private_key
  filename = "${path.module}/sunbird-service-account-key.json"
}

