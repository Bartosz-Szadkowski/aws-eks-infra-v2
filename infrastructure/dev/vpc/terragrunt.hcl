include "root" {
  path = find_in_parent_folders()
}

// terraform {
//   source  = "tfr:///terraform-aws-modules/vpc/aws?version=5.8.1"
// }

// inputs = {
//   name = "dev-vpc"
//   cidr = "10.1.0.0/18"
//   azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
//   private_subnets = ["10.1.24.0/21", "10.1.32.0/21", "10.1.40.0/21"]
//   database_subnets    = ["10.1.48.0/21", "10.1.56.0/21", "10.1.64.0/21"]
//   public_subnets = ["10.1.0.0/21", "10.1.8.0/21", "10.1.16.0/21"]
//   enable_nat_gateway = true

//   tags = {
//     Terraform = "true"
//     Environment = "dev"
//   }
// }