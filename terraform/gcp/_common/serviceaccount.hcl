# serviceaccount.hcl

# Load environment variables from the parent environment.hcl
locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  environment      = local.environment_vars.locals.environment
  building_block   = local.environment_vars.locals.building_block
}

terraform {
  # Reference the service account module
  source = "../../modules//serviceaccount/"
}

dependency "gke" {
  config_path = "../gke"  # Path to gke.hcl

  mock_outputs = {
    cluster_name = "ed-sunbird-cluster"
    namespace    = "sunbird"
  }
}

# Pass inputs to the service account module
inputs = {
  environment     = local.environment
  building_block  = local.building_block
  cluster_name    = dependency.gke.outputs.cluster_name
  namespace       = dependency.gke.outputs.namespace
}

