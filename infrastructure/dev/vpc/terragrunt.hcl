include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  vpc_cidr_block                  = "10.1.0.0/17"
  public_subnets_cidr_blocks      = ["10.1.0.0/19", "10.1.32.0/19"]
  private_subnets_eks_cidr_blocks = ["10.1.64.0/20", "10.1.80.0/20"]
  private_subnets_rds_cidr_blocks = ["10.1.96.0/21", "10.1.104.0/21"]
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}