variable "project_id" {
  type        = string
  description = "The ID of the GCP project."
}

variable "environment_name" {
  type        = string
  description = "Environment name. All resources will be prefixed with this value."
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

