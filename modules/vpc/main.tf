####################
## VPC
####################

resource "aws_vpc" "this" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  # These are set to true to allow worker nodes join the cluster 
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.tags["Environment"]}-vpc"
  }
}

####################
## PUBLIC SUBNETS
####################
resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidr_blocks)

  vpc_id = aws_vpc.this.id 
  cidr_block = var.public_subnets_cidr_blocks[count.index]

  tags = {
    Name = "${var.tags["Environment"]}-public-subnet-${count.index + 1}"
  }
}


####################
## PRIVATE SUBNETS EKS
####################
resource "aws_subnet" "private_eks" {
  count = length(var.private_subnets_eks_cidr_blocks)

  vpc_id = aws_vpc.this.id 
  cidr_block = var.private_subnets_eks_cidr_blocks[count.index]

  tags = {
    Name = "${var.tags["Environment"]}-private-subnet-${count.index + 1}"
  }
}

