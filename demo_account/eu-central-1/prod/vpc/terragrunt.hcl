include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=3.19.0"
}

# Easy to see all inputs
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

inputs = {
  name            = "${local.app_name}-${local.env}"
  cidr            = "10.3.0.0/16"
  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.3.0.0/24", "10.3.1.0/24", "10.3.2.0/24"] # reserved CIDRS for future use: 10.3.(3,4,5).0/24
  public_subnets  = ["10.3.6.0/24", "10.3.7.0/24", "10.3.8.0/24"] # reserved CIDRS for future use: 10.3.(9,10,11).0/24

  enable_nat_gateway            = true
  single_nat_gateway            = true
  enable_dns_hostnames          = true
  manage_default_security_group = true

  private_subnet_tags = {
    "subnet_type"                                          = "private",
    "kubernetes.io/role/internal-elb"                      = "1",
    "kubernetes.io/cluster/${local.app_name}-${local.env}" = "shared"
  }

  public_subnet_tags = {
    "subnet_type"                                          = "private",
    "kubernetes.io/role/internal-elb"                      = "1",
    "kubernetes.io/cluster/${local.app_name}-${local.env}" = "shared"
  }

  tags = local.tags
}




