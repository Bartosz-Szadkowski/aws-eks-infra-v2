include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/s3"
}

dependency "iam" {
  config_path = "../iam"
  mock_outputs = {
    python_web_app_pod_role_arn = "arn:aws:iam::123456789012:role/MyExampleRole"
  }
}

generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        aws = {
          source = "hashicorp/aws"
          version = "5.66.0"
        }
      }
    }
EOF
}

inputs = {
  bucket_prefix = "application-bucket-esta-v6"
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}