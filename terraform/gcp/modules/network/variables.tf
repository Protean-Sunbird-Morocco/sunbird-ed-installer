variable "project_id" {
  type        = string
  description = "The ID of the GCP project."
  default     = "sunbird-morocco-sandbox-434709"
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

variable "location" {
  type        = string
  description = "GCP region to create the resources."
  default     = "asia-south1"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the resources."
  default     = {}
}

variable "vpc_cidr" {
  type        = string
  description = "GCP VPC CIDR range."
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type        = string
  description = "GCP subnet CIDR range."
  default     = "10.0.1.0/24"
}

