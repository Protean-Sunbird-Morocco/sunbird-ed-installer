provider "google" {
  project     = var.project_id
  credentials = file("key.json")
}

data "google_compute_network" "existing_vpc" {
  name = var.existing_vpc_name
}

data "google_compute_subnetwork" "existing_subnet" {
  name   = var.existing_subnet_name
  region = var.primary_region
}

resource "google_compute_global_address" "static_ip" {
  name = "${var.environment_name}-static-ip"
}

resource "google_compute_managed_ssl_certificate" "ssl_certificate" {
  name = "${var.environment_name}-ssl-cert"
  managed {
    domains = [var.domain_name]
  }
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name            = "${var.environment_name}-https-proxy"
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_certificate.id]
  url_map         = google_compute_url_map.lb_url_map.id
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name       = "${var.environment_name}-frontend-service"
  target     = google_compute_target_https_proxy.https_proxy.id
  port_range = "443"
  ip_address = google_compute_global_address.static_ip.address
  ip_protocol = "TCP"
}

resource "google_compute_url_map" "lb_url_map" {
  name            = "${var.environment_name}-loadbalancer"
  default_service = google_compute_backend_service.backend.id
}

# Global Network Endpoint Group (NEG) for external IP
resource "google_compute_global_network_endpoint_group" "internet_neg" {
  name                = "${var.environment_name}-internet-neg"
  network_endpoint_type = "INTERNET_IP_PORT"
}

resource "google_compute_global_network_endpoint" "add_endpoint" {
  global_network_endpoint_group = google_compute_global_network_endpoint_group.internet_neg.id
  ip_address = "34.118.230.66" 
  port       = 80
}

resource "google_compute_backend_service" "backend" {
  name                  = "${var.environment_name}-backend-service"
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = google_compute_global_network_endpoint_group.internet_neg.id
    balancing_mode = "UTILIZATION"
  }
}

