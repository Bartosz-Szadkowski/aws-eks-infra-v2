include "root" {
  path = find_in_parent_folders()
}

terraform {
  source  = "tfr:///terraform-aws-modules/eks/aws?version=20.24.0"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  cluster_name    = "dev-cluster"
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = [dependency.vpc.outputs.private_subnets[0], dependency.vpc.outputs.private_subnets[1], dependency.vpc.outputs.private_subnets[2]]
  control_plane_subnet_ids = [dependency.vpc.outputs.private_subnets[3], dependency.vpc.outputs.private_subnets[4], dependency.vpc.outputs.private_subnets[5]]

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      // ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 4
      desired_size = 2
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  // access_entries = {
  //   # One access entry with a policy associated
  //   example = {
  //     kubernetes_groups = []
  //     principal_arn     = "arn:aws:iam::123456789012:role/something"

  //     policy_associations = {
  //       example = {
  //         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  //         access_scope = {
  //           namespaces = ["default"]
  //           type       = "namespace"
  //         }
  //       }
  //     }
  //   }
  // }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}