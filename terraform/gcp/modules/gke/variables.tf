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
  default     = "ed"  # Set a default value or override from `environment.hcl`
}


variable "subnet_cidr" {
  description = "The CIDR range for the subnetwork."
  type        = string
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


