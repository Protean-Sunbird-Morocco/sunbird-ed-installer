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

# Declare google_client_config data source
data "google_client_config" "provider" {}

# Define locals based on the provided variables
locals {
  common_tags = {
    environment    = var.environment
    building_block = var.building_block
  }
  environment_name = "${var.building_block}-${var.environment}"
}

# Reference the existing VPC
data "google_compute_network" "existing_vpc" {
  name    = "ed-sunbird-vpc"
  project = var.project_id
}

# Reference the existing Subnet
data "google_compute_subnetwork" "existing_subnet" {
  name    = "ed-sunbird-subnet"
  region  = var.location
  project = var.project_id
}

# GKE Cluster using existing VPC and Subnet
resource "google_container_cluster" "primary" {
  name                     = "${local.environment_name}-cluster"
  location                 = var.location
  network                  = data.google_compute_network.existing_vpc.self_link
  subnetwork               = data.google_compute_subnetwork.existing_subnet.self_link
  remove_default_node_pool = true

  initial_node_count = 1
  master_auth {
    client_certificate_config {
      issue_client_certificate = true
    }
  }
}

# GKE Worker Node Pool
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
  }

  autoscaling {
    min_node_count = var.worker_node_min_count
    max_node_count = var.worker_node_max_count
  }

  depends_on = [google_container_cluster.primary]
}

# Get the Kubernetes cluster credentials
data "google_container_cluster" "primary" {
  name     = google_container_cluster.primary.name
  location = var.location
  project  = var.project_id
}

# Run gcloud command to update kubeconfig
resource "null_resource" "configure_kubeconfig" {
  depends_on = [google_container_cluster.primary]

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.location} --project ${var.project_id}"
  }
}

