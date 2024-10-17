include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/eks"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id                 = "vpc-0e66df9decdd3d2e5"
    private_eks_subnet_ids = ["subnet-0b29a9c0e140021a5", "subnet-0d8a03327f8ab0d24"]
    vpc_cidr_block         = "10.0.0.0/16"
  }
}

dependency "bastion" {
  config_path = "../bastion"
  mock_outputs = {
    instance_role_arn = "arn:aws:iam::${get_aws_account_id()}:user/cloud_user"
  }
}

inputs = {
  cluster_version        = 1.26
  vpc_id                 = dependency.vpc.outputs.vpc_id
  subnet_ids             = dependency.vpc.outputs.private_eks_subnet_ids
  vpc_cidr_block         = dependency.vpc.outputs.vpc_cidr_block
  admin_iam_role         = dependency.bastion.outputs.instance_role_arn
  github_actions_role    = "arn:aws:iam::${get_aws_account_id()}:role/GitHubActionsRoleEsta"
  master_admin_iam_arn   = "arn:aws:iam::${get_aws_account_id()}:user/cloud_user"
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}