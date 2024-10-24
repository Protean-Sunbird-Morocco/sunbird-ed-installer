variable "environment" {
  type        = string
  description = "Environment name. All resources will be prefixed with this value."
}

variable "project_id" {
  type        = string
  description = "The GCP project ID."
}

variable "gcp_region" {
  type        = string
  description = "The region in which to create resources."
}

variable "storage_bucket_private" {
  type        = string
  description = "Private GCS bucket name."
}

variable "location" {
  description = "The region for Google Cloud resources."
  type        = string
}

variable "base_location" {
  type        = string
  description = "Location of the Terraform execution folder."
}

variable "rsa_keys_count" {
  type        = number
  description = "Number of RSA keys to generate."
  default     = 2
}

variable "random_string" {
  type        = string
  description = "A random string used for encryption/masking. Should be 12-24 characters long."
  validation {
    condition     = length(var.random_string) >= 12 && length(var.random_string) <= 24
    error_message = "The string must be between 12 and 24 characters long."
  }
}

