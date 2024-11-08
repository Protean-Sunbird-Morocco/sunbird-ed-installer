locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  environment = local.environment_vars.locals.environment
  building_block = local.environment_vars.locals.building_block
  random_string = local.environment_vars.locals.random_string
}

terraform {
  source = "../../modules//gke/"
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    network_name = "sunbird-vpc"
    subnet_id    = "sunbird-subnet"
  }
}

inputs = {
  environment           = local.environment
  building_block       = local.building_block
  network_name         = dependency.network.outputs.network_name
  subnet_id            = dependency.network.outputs.subnet_id
}

