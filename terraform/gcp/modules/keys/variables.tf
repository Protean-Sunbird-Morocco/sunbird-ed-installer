variable "environment" {
  type        = string
  default     = "sunbird"
  description = "Environment name. All resources will be prefixed with this value."
}

variable "building_block" {
  description = "Building block name"
  type        = string
  default     = "ed"  # Set a default value or override from `environment.hcl`
}

variable "project_id" {
  type        = string
  description = "The ID of the GCP project."
  default     = "sunbird-morocco-sandbox-434709"
}


variable "storage_bucket_private" {
  type        = string
  description = "Private GCS bucket name."
  default     = "ed-sunbird-private"
}

variable "location" {
  description = "The region for Google Cloud resources."
  type        = string
  default     = "asia-south1"
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

