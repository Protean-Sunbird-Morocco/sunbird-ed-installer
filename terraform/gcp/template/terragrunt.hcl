generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "gcs" {
    bucket  = "${get_env("GCP_TERRAFORM_BACKEND_BUCKET")}"
    prefix  = "${path_relative_to_include()}/terraform.tfstate"
  }
}
EOF
}

