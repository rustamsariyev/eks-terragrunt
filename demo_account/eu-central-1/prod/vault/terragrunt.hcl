include "root" {
  path = find_in_parent_folders()
}

terraform {
  #source = "git@github.com:rustamsariyev/eks-tf-modules.git//irsa?ref=v0.0.4"
  source = "/mnt/d/Rustam/opsfleet-demo/manage-secrets-k8s/vault//tf-module"
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

dependency "eks" {
  config_path = find_in_parent_folders("eks")
}

inputs = {
  chart_version        = "0.23.0"
  kms_region           = local.region
  eks_cluster_id       = dependency.eks.outputs.cluster_name
  service_account_name = "vault-sa"
  namespace            = "vault"
  tags                 = local.tags
}




