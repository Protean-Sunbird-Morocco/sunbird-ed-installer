variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "location" {
  description = "The region where the resources will be created"
  type        = string
}

variable "service_account_roles" {
  description = "A list of roles to assign to the Google Cloud service account"
  type        = list(string)
  default     = []
}

variable "sa_name" {
  description = "The name of the Kubernetes Service Account (KSA) to bind with the Google Cloud service account"
  type        = string
  default     = "sunbird-serviceaccount"
}

variable "sa_namespace" {
  description = "The namespace in the GKE cluster where the Kubernetes Service Account (KSA) will be created and used"
  type        = string
  default     = "sunbird"
}

variable "service_account_key_path" {
  description = "Filename to store the generated Google Cloud service account key in the current directory"
  type        = string
  default     = "sunbird-service-account-key.json"
}

variable "sa_key_store_bucket" {
  description = "Base name for the GCS bucket to store the Google Cloud service account key (a unique name will be generated)"
  type        = string
  default     = "sa-keys"
}

# New variables for Kubernetes provider configuration

variable "gke_cluster_name" {
  description = "The name of the GKE cluster where the Kubernetes Service Account (KSA) will be created"
  type        = string
  default     = "ed-sunbird-cluster"  # Provide default value for easier configuration
}

variable "gke_cluster_location" {
  description = "The zone or region of the GKE cluster where the Kubernetes Service Account (KSA) will be created"
  type        = string
  default     = "asia-south1"  # Provide default value for easier configuration
}

# Optional variable for storing GCS bucket object path
variable "gcs_key_file_path" {
  description = "Path within the GCS bucket for storing the service account key file"
  type        = string
  default     = "service-accounts/sunbird-service-account-key.json"
}

