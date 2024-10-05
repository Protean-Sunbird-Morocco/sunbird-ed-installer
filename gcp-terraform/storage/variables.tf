variable "environment_name" {
    type        = string
    description = "The name of the environment, derived from the building block and environment."
}

variable "location" {
    type        = string
    description = "GCP region to create the resources."
    default     = "asia-south1"
}

variable "additional_tags" {
    type        = map(string)
    description = "Additional tags for the resources. These tags will be applied to all the resources."
    default     = {}
}

variable "project_id" {
    type        = string
    description = "The project ID in GCP where the resources will be created."
}

variable "storage_class" {
    type        = string
    description = "GCP storage class - Standard / Nearline / Coldline / Archive."
    default     = "STANDARD"
}

variable "location_type" {
    type        = string
    description = "GCP storage location type - MULTI_REGIONAL / REGIONAL."
    default     = "REGIONAL"
}

