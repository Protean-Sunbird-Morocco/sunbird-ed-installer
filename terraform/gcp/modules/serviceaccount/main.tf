# Configure the Google Cloud provider
provider "google" {
  project     = var.project_id
  region      = var.location
  credentials = file("key.json")
}

# Create the service account
resource "google_service_account" "sunbird_serviceaccount" {
  project      = var.project_id
  account_id   = "sunbird-serviceaccount"
  display_name = "Sunbird Service Account"
  description  = "Service account for managing Sunbird resources"
}

# Assign roles to the service account, including the "Owner" role
resource "google_project_iam_member" "sunbird_serviceaccount_roles" {
  for_each = toset(concat(var.service_account_roles, ["roles/owner"]))

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.sunbird_serviceaccount.email}"
}

# Optional: Bind the service account to Kubernetes workloads for Workload Identity
resource "google_service_account_iam_binding" "workload_identity_role" {
  count = (var.sa_name != "" && var.sa_namespace != "") ? 1 : 0

  service_account_id = google_service_account.sunbird_serviceaccount.name
  role               = "roles/iam.workloadIdentityUser"
  members            = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.sa_namespace}/${var.sa_name}]"
  ]
}

# Create a service account key (Always created)
resource "google_service_account_key" "sunbird_serviceaccount_key" {
  service_account_id = google_service_account.sunbird_serviceaccount.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# Save the service account key to a local file in the current directory
resource "local_file" "service_account_key_file" {
  content  = base64decode(google_service_account_key.sunbird_serviceaccount_key.private_key)
  filename = "${path.module}/${var.service_account_key_path}"
}

# Generate a unique suffix for the GCS bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Create a GCS bucket to store the service account key
resource "google_storage_bucket" "sa_key_store" {
  name                        = "${var.sa_key_store_bucket}-${random_id.bucket_suffix.hex}"
  location                    = var.location
  force_destroy               = true  # Set to true for testing; remove in production if not needed
  uniform_bucket_level_access = true
}

# Grant the service account permission to upload objects to the GCS bucket
resource "google_storage_bucket_iam_member" "service_account_storage_access" {
  bucket = google_storage_bucket.sa_key_store.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.sunbird_serviceaccount.email}"
}

# Upload the saved key file to the GCS bucket
resource "google_storage_bucket_object" "gke_service_account_key" {
  name   = "service-accounts/sunbird-service-account-key.json"
  source = local_file.service_account_key_file.filename
  bucket = google_storage_bucket.sa_key_store.name
}

