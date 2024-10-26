include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/Bartosz-Szadkowski/terraform-modules.git//bastion?ref=bastion-v1.1.0"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id                 = "vpc-0e66df9decdd3d2e5"
    private_eks_subnet_ids = ["subnet-0b29a9c0e140021a5", "subnet-0d8a03327f8ab0d24"]
  }
}

inputs = {
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_eks_subnet_ids
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
    region = "us-east-1"
}
provider "random" {

}
EOF
}