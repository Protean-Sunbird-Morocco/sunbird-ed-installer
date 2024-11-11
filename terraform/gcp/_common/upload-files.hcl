# For local development
terraform {
  source = "../../modules//upload-files/"
}

dependency "storage" {
    config_path = "../storage"
    mock_outputs = {
       public_bucket_name = "ed-sunbird-public"
    }
}

inputs = {
  public_bucket_name                 = dependency.storage.outputs.public_bucket_name
}
