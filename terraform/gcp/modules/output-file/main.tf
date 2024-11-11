locals {
  global_values_cloud_file = "${var.base_location}/../global-cloud-values.yaml"
}

resource "local_sensitive_file" "global_cloud_values_yaml" {
  content  = templatefile("${path.module}/global-cloud-values.yaml.tfpl", {
    env                           = var.env,
    environment                   = var.environment,
    building_block                = var.building_block,
    gcp_storage_bucket_key        = var.gcp_storage_bucket_key,
    _public_bucket_name        = var.public_bucket_name,
    private_bucket_name       = var.private_bucket_name,
    random_string                 = var.random_string,
    private_ingressgateway_ip     = var.private_ingressgateway_ip
  })
  filename = local.global_values_cloud_file
}

resource "null_resource" "upload_global_cloud_values_yaml" {
  triggers = {
    command = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "gsutil cp ${local.global_values_cloud_file} gs://${var.private_bucket_name}/${var.environment}-global-cloud-values.yaml"
  }
  depends_on = [ local_sensitive_file.global_cloud_values_yaml ]
}

# Sample code to enable encryption of global values files for GCP
# Encrypted files cannot be passed to helm

# resource "null_resource" "terrahelp_encryption" {
#   triggers = {
#     command = "${timestamp()}"
#   }
#   provisioner "local-exec" {
#     command = "terrahelp encrypt -simple-key=${var.random_string} -file=${local.global_values_keys_file}"
#   }
# }

