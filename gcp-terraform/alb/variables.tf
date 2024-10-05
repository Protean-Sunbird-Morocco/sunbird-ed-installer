variable "project_id" {
  description = "The ID of the project where the resources will be created."
  type        = string
}

variable "environment_name" {
  description = "Environment name for resources."
  type        = string
}

variable "existing_vpc_name" {
  description = "The name of the existing VPC network"
  type        = string
  default     = "sunbird-vpc"
}

variable "existing_subnet_name" {
  description = "The name of the existing subnet"
  type        = string
  default     = "sunbird-subnet"
}

variable "primary_region" {
  description = "The region where the existing subnet is located"
  type        = string
  default     = "asia-south1"
}


variable "domain_name" {
  description = "Domain name for the SSL certificate."
  type        = string
}

variable "zones" {
  description = "The GCP zones where the NEGs will be created."
  type        = list(string)
  default     = ["asia-south1-a", "asia-south1-b", "asia-south1-c"]
}

