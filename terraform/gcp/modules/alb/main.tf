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

resource "google_compute_network" "vpc_network" {
  name                   = "${var.environment_name}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.environment_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.location
  network       = google_compute_network.vpc_network.id

  depends_on = [google_compute_network.vpc_network]
}

resource "google_container_cluster" "primary" {
  name                     = "${var.environment_name}-cluster"
  location                 = var.location
  network                  = google_compute_network.vpc_network.name
  subnetwork               = google_compute_subnetwork.subnet.name
  remove_default_node_pool = true  

  initial_node_count = 1 
  master_auth {
    client_certificate_config {
      issue_client_certificate = true
    }
  }
}

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


