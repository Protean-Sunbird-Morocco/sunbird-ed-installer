provider "google" {
  project     = var.project_id
  region      = var.location
  credentials = file("key.json")
}

provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/config")
  }
}

provider "kubernetes" {
  config_path = pathexpand("~/.kube/config")
}

data "google_client_config" "provider" {}

locals {
  common_tags = {
    environment    = var.environment
    building_block = var.building_block
  }
  environment_name = "${var.building_block}-${var.environment}"
}

# Get the existing VPC and subnet
data "google_compute_network" "existing_vpc" {
  name    = "ed-sunbird-vpc"
  project = var.project_id
}

data "google_compute_subnetwork" "existing_subnet" {
  name    = "ed-sunbird-subnet"
  region  = var.location
  project = var.project_id
}

# Create the GKE Cluster with Workload Identity enabled
resource "google_container_cluster" "primary" {
  name                     = "${local.environment_name}-cluster"
  location                 = var.location
  network                  = data.google_compute_network.existing_vpc.self_link
  subnetwork               = data.google_compute_subnetwork.existing_subnet.self_link
  remove_default_node_pool = true

  initial_node_count = 1

  workload_identity_config {
    workload_pool = "${data.google_client_config.provider.project}.svc.id.goog"
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = true
    }
  }
}

# Create a node pool for GKE with Workload Identity enabled
resource "google_container_node_pool" "worker_pool" {
  cluster    = google_container_cluster.primary.name
  name       = "worker-node-pool"
  location   = var.location
  node_count = var.worker_node_count

  node_config {
    machine_type = var.worker_node_size

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  autoscaling {
    min_node_count = var.worker_node_min_count
    max_node_count = var.worker_node_max_count
  }

  depends_on = [google_container_cluster.primary]
}

# Configure kubectl with the new cluster credentials
resource "null_resource" "configure_kubeconfig" {
  depends_on = [google_container_cluster.primary]

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.location} --project ${var.project_id}"
  }
}

# Step 1: Create GCP Service Account (GSA) with Owner Permissions
resource "google_service_account" "sunbird_serviceaccount" {
  account_id   = "sunbird-gsa"
  display_name = "sunbird-gsa"
}

resource "google_project_iam_member" "sunbird_owner_access" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.sunbird_serviceaccount.email}"
}

# Step 2: Generate Service Account Key
resource "google_service_account_key" "sunbird_serviceaccount_key" {
  service_account_id = google_service_account.sunbird_serviceaccount.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# Step 3: Save the Service Account Key to a Local File
resource "local_file" "service_account_key_file" {
  content  = base64decode(google_service_account_key.sunbird_serviceaccount_key.private_key)
  filename = "${path.module}/${var.service_account_key_path}"
}

# Step 4: Generate a Unique Suffix for the GCS Bucket
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Step 5: Create a GCS Bucket to Store the Service Account Key
resource "google_storage_bucket" "sa_key_store" {
  name                        = "${var.sa_key_store_bucket}-${random_id.bucket_suffix.hex}"
  location                    = var.location
  force_destroy               = true
  uniform_bucket_level_access = true
}

# Step 6: Grant the Service Account Permission to Upload Objects to the GCS Bucket
resource "google_storage_bucket_iam_member" "service_account_storage_access" {
  bucket = google_storage_bucket.sa_key_store.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.sunbird_serviceaccount.email}"
}

# Step 7: Upload the Service Account Key to the GCS Bucket
resource "google_storage_bucket_object" "gke_service_account_key" {
  name   = "service-accounts/sunbird-service-account-key.json"
  source = local_file.service_account_key_file.filename
  bucket = google_storage_bucket.sa_key_store.name
}

# Create the Kubernetes Service Account (KSA) in the 'sunbird' namespace
resource "kubernetes_service_account" "sunbird_ksa" {
  metadata {
    name      = "sunbird-ksa"
    namespace = "sunbird"
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.sunbird_serviceaccount.email
    }
  }
}

# Grant Workload Identity permissions for KSA to impersonate the GSA
resource "google_service_account_iam_binding" "allow_k8s_impersonation" {
  service_account_id = google_service_account.sunbird_serviceaccount.name
  role               = "roles/iam.serviceAccountTokenCreator"
  members = [
    "serviceAccount:${data.google_client_config.provider.project}.svc.id.goog[sunbird/sunbird-ksa]"
  ]
}


