variable "env" {
    type        = string
    default     = "dev"
    description = "Env name. All resources will be prefixed with this value in helm charts."
}

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

variable "gcp_storage_bucket_key" {
  description = "The key for accessing the Google Cloud Storage bucket"
  type        = string
  default     = "key.json"
}

variable "project_id" {
  type        = string
  description = "The ID of the GCP project."
  default     = "sunbird-morocco-sandbox-434709"
}

variable "public_bucket_name" {
    type        = string
    description = "Public storage bucket name."
    default     = "ed-sunbird-public"
}

variable "private_bucket_name" {
    type        = string
    description = "Private storage bucket name."
    default     = "ed-sunbird-private"
}


variable "base_location" {
    type        = string
    description = "Location of terrafrom execution folder."
}

 variable "random_string" {
    type        = string
    description = "This string will be used to encrypt / mask various values. Use a strong random string in order to secure the applications. The string should be between 12 and 24 characters in length. If you forget the string, the application will stop working and the string cannot be retrieved."
    validation {
      condition     = length(var.random_string) >= 12 || length(var.random_string) <= 24
      error_message = "The string must have a length ranging from 12 to 24 characters."
  }
}
variable "private_ingressgateway_ip" {
    type        = string
    description = "Private LB IP."
}
