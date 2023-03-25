locals {
  env = "prod"

  env_tags = {
    Env = local.env
  }
}
