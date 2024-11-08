variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "location" {
  description = "The region where the resources will be created"
  type        = string
}

variable "service_account_roles" {
  description = "A list of roles to assign to the service account"
  type        = list(string)
  default     = []
}

variable "sa_name" {
  description = "The name of the Kubernetes service account to bind the service account to"
  type        = string
  default     = ""
}

variable "sa_namespace" {
  description = "The namespace of the Kubernetes service account"
  type        = string
  default     = ""
}

variable "service_account_key_path" {
  description = "Filename to store the generated service account key in the current directory"
  type        = string
  default     = "sunbird-service-account-key.json"
}

variable "sa_key_store_bucket" {
  description = "Base name for the GCS bucket to store the service account key (a unique name will be generated)"
  type        = string
  default     = "sa-keys"
}

