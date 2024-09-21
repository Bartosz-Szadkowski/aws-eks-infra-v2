include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/bastion"
}

dependency "vpc" {
  config_path = "../vpc"
  skip_outputs = true
}

inputs = {
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_eks_subnet_ids
}