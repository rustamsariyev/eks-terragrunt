include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:rustamsariyev/eks-tf-modules.git//eks?ref=v0.0.3"
}

locals {
  env_vars     = read_terragrunt_config("env.hcl", read_terragrunt_config(find_in_parent_folders("env.hcl", "does-not-exist.fallback"), { locals = {} }))
  env          = local.env_vars.locals.env
  region_vars  = read_terragrunt_config("region.hcl", read_terragrunt_config(find_in_parent_folders("region.hcl", "does-not-exist.fallback"), { locals = {} }))
  region       = local.region_vars.locals.region
  account_vars = read_terragrunt_config("account.hcl", read_terragrunt_config(find_in_parent_folders("account.hcl", "does-not-exist.fallback"), { locals = {} }))
  account_id   = local.account_vars.locals.account_id
  global_vars  = read_terragrunt_config("global.hcl", read_terragrunt_config(find_in_parent_folders("global.hcl", "does-not-exist.fallback"), { locals = {} }))
  app_name     = local.global_vars.locals.app_name
  tags         = merge(local.global_vars.locals.global_tags, local.env_vars.locals.env_tags)
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc")
}

inputs = {
  create                         = true
  tags                           = local.tags
  cluster_name                   = "${local.app_name}-${local.env}"
  cluster_version                = "1.25"
  cluster_endpoint_public_access = true
  vpc_id                         = dependency.vpc.outputs.vpc_id
  subnet_ids                     = dependency.vpc.outputs.private_subnets
  kms_key_enable_default_policy  = true
  manage_aws_auth_configmap      = true

  eks_managed_node_groups = {
    managed = {
      name           = "managed_node"
      capacity_type  = "ON_DEMAND"
      instance_types = ["t3.large"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1

      # If you want use gp3 EBS volume, you have to use this block.
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 20
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
    }
  }
}




