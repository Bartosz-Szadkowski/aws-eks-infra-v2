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
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.tags["Environment"]}-public-subnet-${count.index + 1}"
  }
}

####################
## IGW 
####################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.tags["Environment"]}-internet-gateway"
  }
}

####################
## PUBLIC RT
####################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
  Name = "${var.tags["Environment"]}-public-rt"
  }
}

resource "aws_route_table_association" "public_association" {
  count        = length(aws_subnet.public)
  subnet_id    = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


####################
## PRIVATE SUBNETS EKS
####################
resource "aws_subnet" "private_eks" {
  count = length(var.private_subnets_eks_cidr_blocks)

  vpc_id = aws_vpc.this.id 
  cidr_block = var.private_subnets_eks_cidr_blocks[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.tags["Environment"]}-private-subnet-eks-${count.index + 1}"
  }
}

####################
## PRIVATE EKS RT
####################

resource "aws_route_table" "private_eks" {
  count  = 2  # Create one route table for each AZ (replace with the number of AZs)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
   Name = "${var.tags["Environment"]}-private-eks-rt-${count.index + 1}" 
  }
}

resource "aws_route_table_association" "private_eks_association" {
  count        = length(aws_subnet.private_eks)
  subnet_id    = aws_subnet.private_eks[count.index].id
  route_table_id = aws_route_table.private_eks[count.index].id
}

####################
## PRIVATE SUBNETS RDS
####################
resource "aws_subnet" "private_rds" {
  count = length(var.private_subnets_rds_cidr_blocks)

  vpc_id = aws_vpc.this.id 
  cidr_block = var.private_subnets_rds_cidr_blocks[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.tags["Environment"]}-private-subnet-rds-${count.index + 1}"
  }
}

####################
## PRIVATE RDS RT
####################

resource "aws_route_table" "private_rds" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.tags["Environment"]}-private-rds-rt"
  }
}

resource "aws_route_table_association" "private_rds_association" {
  count        = length(aws_subnet.private_rds)
  subnet_id    = aws_subnet.private_rds[count.index].id
  route_table_id = aws_route_table.private_rds.id
}

####################
## NAT GW
####################

resource "aws_eip" "nat" {
  count = 2  # Create NAT gateways in both public subnets for HA
  domain = "vpc"
  tags = {
    Name = "${var.tags["Environment"]}-nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count = 2  # One NAT Gateway per public subnet for redundancy
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  tags = {
    Name = "${var.tags["Environment"]}-nat-gw-${count.index + 1}"
  }
}

####################
## AWS ENDPOINTS
####################

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = aws_route_table.private_eks[*].id
  tags = {
    Name = "${var.tags["Environment"]}-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface" 
  subnet_ids = aws_subnet.private_eks[*].id
  tags = {
    Name = "${var.tags["Environment"]}-cloudwatch-logs-endpoint"
  }
}
