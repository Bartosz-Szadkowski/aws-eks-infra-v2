include "root" {
  path = find_in_parent_folders()
}

# BELOW IS THE TF OFFICIAL VPC MODULE, FOR NOW IS USING IN CI/CD SETUP

// terraform {
//   source  = "tfr:///terraform-aws-modules/vpc/aws?version=5.8.1"
// }

// inputs = {
//   name = "dev-vpc"
//   cidr = "10.1.0.0/17"
//   azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
//   // private_subnets = ["10.1.12.0/22", "10.1.16.0/22", "10.1.20.0/22", "10.1.36.0/22", "10.1.40.0/22", "10.1.44.0/22"]
//   private_subnets = ["10.1.12.0/22", "10.1.16.0/22", "10.1.20.0/22"] 
//   database_subnets    = ["10.1.24.0/22", "10.1.28.0/22", "10.1.32.0/22"]
//   public_subnets = ["10.1.0.0/22", "10.1.4.0/22", "10.1.8.0/22"]
//   enable_nat_gateway = true

//   tags = {
//     Terraform = "true"
//     Environment = "dev"
//   }
// }

# BELOW IS THE CUSTOM MODULE USAGE, TO BE USED WHEN OTHER CUSTOM MODULES WILL BE READY

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