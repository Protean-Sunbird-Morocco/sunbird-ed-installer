# Resource for rclone configuration
resource "local_sensitive_file" "rclone_config" {
  content  = templatefile("${path.module}/config.tfpl", {
    sunbird_public_artifacts_account       = var.sunbird_public_artifacts_account,
    sunbird_public_artifacts_account_sas_url = var.sunbird_public_artifacts_account_sas_url,
    gcp_bucket                             = var.gcp_bucket,
    gcp_credentials                        = var.gcp_credentials
  })
  filename = pathexpand("~/.config/rclone/rclone.conf")
}

# Resource to copy files from Sunbird to GCP
resource "null_resource" "copy_from_sunbird_to_gcp" {
  triggers = {
    command = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "rclone copy sunbird:${var.sunbird_public_artifacts_container} gcpbucket:${var.gcp_bucket} --transfers 600 --checkers 600 --exclude .terragrunt-source-manifest"
  }
  depends_on = [local_sensitive_file.rclone_config]
}

# Get JSON template files
locals {
  template_files = fileset("${path.module}", "*.json")
}

# Resource for creating output files
resource "local_file" "output_files" {
  for_each = toset(local.template_files)
  content  = templatefile("${path.module}/${each.value}", {
    cloud_storage_schema_url = "gs://${var.gcp_bucket}"  # Update with GCP URL format
  })
  filename = "${path.module}/${each.value}"
}

# Resource to upload JSON files to GCP bucket
resource "null_resource" "upload_rc_schemas_to_gcp" {
  triggers = {
    command = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "rclone copy ${path.module} gcpbucket:${var.gcp_bucket}/schemas --transfers 25 --checkers 25 --exclude .terragrunt-source-manifest"
  }
  depends_on = [local_sensitive_file.rclone_config]
}

