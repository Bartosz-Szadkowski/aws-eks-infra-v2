include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/secrets"
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