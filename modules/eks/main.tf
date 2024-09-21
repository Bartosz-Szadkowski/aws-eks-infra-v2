# Create EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = "${var.tags["Environment"]}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  bootstrap_self_managed_addons = true

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

# Retrieve the latest Amazon EKS optimized AMI ID using SSM
data "aws_ssm_parameter" "eks_ami" {
  name            = "/aws/service/eks/optimized-ami/${var.cluster_version}/amazon-linux-2/recommended/image_id"
  with_decryption = false
}

# Create an Auto Scaling Group (ASG) for EKS worker nodes using the Launch Template
resource "aws_autoscaling_group" "eks_nodes" {
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.subnet_ids
  launch_template {
    id      = aws_launch_template.eks_nodes_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "kubernetes.io/cluster/${aws_eks_cluster.this.name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

# Launch Template for Worker Nodes
resource "aws_launch_template" "eks_nodes_lt" {
  name_prefix   = "${var.tags["Environment"]}-nodes-"
  image_id      = data.aws_ssm_parameter.eks_ami.value # Latest EKS Optimized AMI
  instance_type = var.instance_type
  key_name      = null

  iam_instance_profile {
    name = aws_iam_instance_profile.eks_node_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.worker_sg.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.ebs_volume_size
      volume_type = "gp2"
    }
  }

  lifecycle {
    create_before_destroy = true
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
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn = var.admin_iam_role

  access_scope {
    type = "cluster"
  }
}