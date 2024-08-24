include "root" {
  path = find_in_parent_folders()
}

terraform {
  source  = "terraform-aws-modules/vpc/aws"
  // version = "5.13.0"
}

inputs = {
  name = "dev-vpc"
  cidr = "10.1.0.0/18"
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.1.8.0/21", "10.1.16.0/21", "10.1.24.0/22", "10.1.28.0/22"]
  public_subnets = ["10.1.0.0/22", "10.1.4.0/22"]
  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}