variable "project_id" {
  description = "The ID of the project where the resources will be created."
  type        = string
  default     = "sunbird-morocco-sandbox-434709"
}

variable "location" {
  description = "The GCP region to deploy resources."
  type        = string
  default     = "asia-south1"
}

variable "environment" {
  description = "The name of the environment, e.g., dev, stage, prod."
  type        = string
  default     = "sunbird"
}

variable "building_block" {
  description = "Building block name"
  type        = string
  default     = "ed"
}

variable "subnet_cidr" {
  description = "The CIDR range for the subnetwork."
  type        = string
  default     = "10.0.1.0/24"
}

variable "worker_node_count" {
  description = "Number of nodes for the worker node pool."
  type        = number
  default     = 5
}

variable "worker_node_size" {
  description = "The machine type for the worker node pool."
  type        = string
  default     = "n2d-standard-4"
}

variable "worker_node_min_count" {
  description = "Minimum number of nodes for autoscaling in the worker node pool."
  type        = number
  default     = 5
}

variable "worker_node_max_count" {
  description = "Maximum number of nodes for autoscaling in the worker node pool."
  type        = number
  default     = 10
}

# New variable to control namespace creation
variable "create_namespace" {
  description = "Boolean to control whether Terraform should create the namespace if it does not exist."
  type        = bool
  default     = true
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


