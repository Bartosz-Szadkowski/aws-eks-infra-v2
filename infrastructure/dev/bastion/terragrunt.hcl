include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/bastion"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
 vpc_id = dependency.vpc.outputs.vpc_id
 subnet_id = dependency.vpc.outputs.private_eks_subnet_ids[0]
}