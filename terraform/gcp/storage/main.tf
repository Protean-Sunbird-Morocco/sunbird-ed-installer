provider "google" {
  project     = var.project_id
  region      = var.location
  credentials = file("/Users/mansi/Downloads/sunbird-morocco-sandbox-434709-c0322f0c3ef4 (1).json")
}

locals {
  environment_name = var.environment_name 
}

resource "google_storage_bucket" "storage_bucket_private" {
  name                         = "${local.environment_name}-private"
  location                     = var.location
  storage_class                = "STANDARD" 
  force_destroy                = false

  labels = {
    environment = local.environment_name 
  }

  versioning {
    enabled = false
  }

  cors {
    max_age_seconds = 200
    method          = ["GET", "HEAD", "OPTIONS", "PUT"]
    origin          = ["*"]
    response_header = ["Access-Control-Allow-Origin", "Access-Control-Allow-Methods"]
  }

  uniform_bucket_level_access = false 
}

resource "google_storage_bucket" "storage_bucket_public" {
  name                         = "${local.environment_name}-public"
  location                     = var.location
  storage_class                = "STANDARD"
  force_destroy                = false

  labels = {
    environment = local.environment_name 
  }

  versioning {
    enabled = false
  }

  cors {
    max_age_seconds = 200
    method          = ["GET", "HEAD", "OPTIONS", "PUT"]
    origin          = ["*"]
    response_header = ["Access-Control-Allow-Origin", "Access-Control-Allow-Methods"]
  }

  uniform_bucket_level_access = false 
}

resource "google_storage_bucket_iam_member" "storage_bucket_public_access" {
  bucket = google_storage_bucket.storage_bucket_public.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket" "reports_bucket_private" {
  name                         = "${local.environment_name}-reports"
  location                     = var.location
  storage_class                = "STANDARD"
  force_destroy                = false

  labels = {
    environment = local.environment_name 
  }

  versioning {
    enabled = false
  }

  cors {
    max_age_seconds = 200
    method          = ["GET", "HEAD", "OPTIONS", "PUT"]
    origin          = ["*"]
    response_header = ["Access-Control-Allow-Origin", "Access-Control-Allow-Methods"]
  }

  uniform_bucket_level_access = false
}

resource "google_storage_bucket" "telemetry_bucket_private" {
  name                         = "${local.environment_name}-telemetry-data-store"
  location                     = var.location
  storage_class                = "STANDARD"
  force_destroy                = false

  labels = {
    environment = local.environment_name 
  }

  versioning {
    enabled = false
  }

  cors {
    max_age_seconds = 200
    method          = ["GET", "HEAD", "OPTIONS", "PUT"]
    origin          = ["*"]
    response_header = ["Access-Control-Allow-Origin", "Access-Control-Allow-Methods"]
  }

  uniform_bucket_level_access = false
}

resource "google_storage_bucket" "backups_bucket_private" {
  name                         = "${local.environment_name}-backups"
  location                     = var.location
  storage_class                = "STANDARD"
  force_destroy                = false

  labels = {
    environment = local.environment_name  
  }

  versioning {
    enabled = false
  }

  cors {
    max_age_seconds = 200
    method          = ["GET", "HEAD", "OPTIONS", "PUT"]
    origin          = ["*"]
    response_header = ["Access-Control-Allow-Origin", "Access-Control-Allow-Methods"]
  }

  uniform_bucket_level_access = false 
}

resource "google_storage_bucket" "flink_state_bucket_private" {
  name                         = "${local.environment_name}-flink-state-backend"
  location                     = var.location
  storage_class                = "STANDARD"
  force_destroy                = false

  labels = {
    environment = local.environment_name  
  }

  versioning {
    enabled = false
  }

  cors {
    max_age_seconds = 200
    method          = ["GET", "HEAD", "OPTIONS", "PUT"]
    origin          = ["*"]
    response_header = ["Access-Control-Allow-Origin", "Access-Control-Allow-Methods"]
  }

  uniform_bucket_level_access = false 
}

resource "google_storage_bucket" "dial_state_bucket_public" {
  name                         = "${local.environment_name}-dial"
  location                     = var.location
  storage_class                = "STANDARD"
  force_destroy                = false

  labels = {
    environment = local.environment_name 
  }

  versioning {
    enabled = false
  }

  cors {
    max_age_seconds = 200
    method          = ["GET", "HEAD", "OPTIONS", "PUT"]
    origin          = ["*"]
    response_header = ["Access-Control-Allow-Origin", "Access-Control-Allow-Methods"]
  }

  uniform_bucket_level_access = false 
}

resource "google_storage_bucket_iam_member" "dial_state_bucket_public_access" {
  bucket = google_storage_bucket.dial_state_bucket_public.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
} 
