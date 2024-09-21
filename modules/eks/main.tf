##################
### EKS CLUSTER
##################
resource "aws_eks_cluster" "this" {
  name     = "${var.tags["Environment"]}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }

  version = var.cluster_version
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy]
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
  tags = {
    Name = "${var.tags["Environment"]}-eks-cluster"
  }
}
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.this.version}/amazon-linux-2/recommended/release_version"
}

resource "aws_eks_node_group" "eks_worker_nodes_group" {
 cluster_name = aws_eks_cluster.this.name 
 node_group_name = "${var.tags["Environment"]}-eks-worker-nodes" 
 node_role_arn = aws_iam_role.eks_worker_node_role.arn
 release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
 subnet_ids = var.subnet_ids
 capacity_type = "ON_DEMAND"
 instance_types = [ "t2.small" ]
 scaling_config {
   desired_size = 2
   max_size = 2
   min_size = 0
 }
 update_config {
   max_unavailable = 1
 }
 

}

# Security Group for Worker Nodes
resource "aws_security_group" "worker_sg" {
  vpc_id      = var.vpc_id
  description = "Security group for the EKS Worker Nodes"
  tags = {
    Name = "${var.tags["Environment"]}-eks-worker-nodes-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "worker_egress" {
  security_group_id = aws_security_group.worker_sg.id
  cidr_ipv4         = var.vpc_cidr_block
  ip_protocol       = "-1"
  description       = "Allow all traffic from eks worker nodes in vpc"
}

resource "aws_vpc_security_group_ingress_rule" "worker_ingress" {
  security_group_id = aws_security_group.worker_sg.id
  cidr_ipv4         = var.vpc_cidr_block
  ip_protocol       = "tcp"
  from_port         = "0"
  to_port           = "65535"
  description       = "Allow all traffic to eks worker nodes in vpc"
}


# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster_sg" {
  vpc_id      = var.vpc_id
  description = "Security group for the EKS Cluster"
  tags = {
    Name = "${var.tags["Environment"]}-eks-cluster-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "eks_cluster_egress" {
  security_group_id = aws_security_group.eks_cluster_sg.id
  cidr_ipv4         = var.vpc_cidr_block
  ip_protocol       = "-1"
  description       = "Allow all traffic from eks cluster in vpc"
}

resource "aws_vpc_security_group_ingress_rule" "eks_cluster_ingress" {
  security_group_id = aws_security_group.eks_cluster_sg.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = "443"
  to_port           = "443"
  ip_protocol       = "tcp"
  description       = "Allow traffic from eks worker nodes in vpc"
}

resource "aws_eks_access_entry" "admin_access_entry" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.admin_iam_role
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_access_policy_association" {
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.admin_iam_role

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "master_admin_access_entry" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.master_admin_iam_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "master_admin_access_policy_association" {
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.master_admin_iam_arn

  access_scope {
    type = "cluster"
  }
}