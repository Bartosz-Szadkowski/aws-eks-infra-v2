include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/Bartosz-Szadkowski/terraform-modules.git//secrets?ref=secrets-v1.1.0"
}

inputs {
  allowed_roles = ["arn:aws:iam::${get_aws_account_id()}:role/GitHubActionsRoleEsta", "arn:aws:iam::${get_aws_account_id()}:user/cloud_user"]
}

generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        random = {
      source = "hashicorp/random"
      version = "3.6.3"
    }
      }
    }
EOF
}