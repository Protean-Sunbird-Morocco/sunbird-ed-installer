provider "google" {
  project     = var.project_id
  region      = var.location
  credentials = file("key.json")
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

resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.environment_name}-allow-http-https"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
  target_tags   = ["http-server", "https-server"]

  depends_on = [google_compute_network.vpc_network]
}

