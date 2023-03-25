locals {
  app_name = "webapp"
  
  global_tags = {
    IacPath     = "eks-tg${split("${get_parent_terragrunt_dir()}", get_original_terragrunt_dir())[1]}"
    CreatedBy   = "terraform"
    CompanyName = "Demo"
  }
}
