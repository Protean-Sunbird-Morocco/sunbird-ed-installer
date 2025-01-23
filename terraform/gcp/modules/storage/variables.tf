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

