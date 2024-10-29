include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/Bartosz-Szadkowski/terraform-modules.git//iam?ref=iam-v1.1.0"
}

