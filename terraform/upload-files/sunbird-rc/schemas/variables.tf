# Existing variables for Azure storage account details
# variable "storage_account_name" {
#     type        = string
#     description = "Storage account name."
# }

# variable "storage_container_public" {
#     type        = string
#     description = "Public storage container name with blob access."
# }

# variable "storage_account_primary_access_key" {
#     type        = string
#     description = "Storage account primary access key."
# }

# Sunbird public artifacts details
variable "sunbird_public_artifacts_account" {
    type        = string
    description = "The public account name where storage artifacts are published for this release."
    default     = "downloadableartifacts"
}

variable "sunbird_public_artifacts_account_sas_url" {
    type        = string
    description = "The readonly sas token url for the Sunbird public account."
    default     = "https://downloadableartifacts.blob.core.windows.net/?sv=2022-11-02&ss=bf&srt=co&sp=rlitfx&se=2026-08-30T20:37:29Z&st=2024-07-10T12:37:29Z&spr=https&sig=hcXksbrbR%2BJgCB0EKxiwHCSsQ6r2eSlyOVnqnjxFOH0%3D"
}

variable "sunbird_public_artifacts_container" {
    type        = string
    description = "The container name dedicated for this release which holds the storage artifacts."
    default     = "release700"
}

# New variables for Google Cloud Storage (GCP)

variable "gcp_bucket" {
    type        = string
    description = "The GCP bucket name where artifacts will be uploaded."
    default     = "sunbird-public"
}

variable "gcp_credentials" {
    type        = string
    description = "The path to the GCP credentials file for authenticating with the GCP bucket."
    default     = "/Users/mansi/Downloads/sunbird-morocco-sandbox-434709-c0322f0c3ef4 (1).json"
}

