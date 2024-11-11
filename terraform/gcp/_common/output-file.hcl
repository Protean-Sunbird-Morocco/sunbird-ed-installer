locals {
  # This section will be enabled after final code is pushed and tagged
  # source_base_url = "github.com/<org>/modules.git//app"
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  env = local.environment_vars.locals.env
  environment = local.environment_vars.locals.environment
  building_block = local.environment_vars.locals.building_block
  random_string  = local.environment_vars.locals.random_string
}

# For local development
terraform {
  source = "../../modules//output-file/"
}

dependency "storage" {
    config_path = "../storage"
    mock_outputs = {

       private_bucket_name = "ed-sunbird-private"
       public_bucket_name = "ed-sunbird-public"
    }
}

dependency "gke" {
    config_path = "../gke"
}

inputs = {
  env                                = local.environment_vars.locals.env
  environment                        = local.environment
  building_block                     = local.building_block
  public_bucket_name                 = dependency.storage.outputs.public_bucket_name
  private_bucket_name                = dependency.storage.outputs.private_bucket_name
  random_string                      = local.random_string
  
}
