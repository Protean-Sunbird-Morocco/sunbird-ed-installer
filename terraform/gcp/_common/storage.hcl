locals {
  # This section will be enabled after final code is pushed and tagged
  # source_base_url = "github.com/<org>/modules.git//app"
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  environment = local.environment_vars.locals.environment
  building_block = local.environment_vars.locals.building_block
}

# For local development
terraform {
  source = "../../modules//storage/"
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    network_name = "ed-sunbird-vpc"
    subnet_id    = "ed-sunbird-subnet"
  }
}

inputs = {
  environment                 = local.environment
  building_block      = local.building_block
}
