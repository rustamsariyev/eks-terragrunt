locals {
  # load region variables
  region_vars = read_terragrunt_config("region.hcl", read_terragrunt_config(find_in_parent_folders("region.hcl", "does-not-exist.fallback"), { locals = {} }))
  # load account variables
  account_vars = read_terragrunt_config("account.hcl", read_terragrunt_config(find_in_parent_folders("account.hcl", "does-not-exist.fallback"), { locals = {} }))
}

terraform {
}

generate "provider" {
  if_exists = "overwrite_terragrunt"
  path      = "provider_remove.tf"

  contents = <<EOF
    provider "aws" {
      region = "${local.region_vars.locals.region}"

      assume_role {
        role_arn = "arn:aws:iam::${local.account_vars.locals.account_id}:role/terraform"
      }
      
      allowed_account_ids = ["${local.account_vars.locals.account_id}"]
    }
  EOF
}

remote_state {
  backend = "s3"
  generate = {
    if_exists = "overwrite_terragrunt"
    path      = "backend_remove.tf"
  }
  config = {
    key            = "${path_relative_to_include()}.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    bucket         = "${local.account_vars.locals.account_name}-${local.account_vars.locals.account_id}-tf-state"
    dynamodb_table = "${local.account_vars.locals.account_name}-tf-state-lock"
  }
}