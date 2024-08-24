remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket         = "my-terraform-esta-state-v1"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "my-lock-esta-table-v1"
    skip_bucket_versioning = true   # Optional, skip enabling versioning on the bucket
    skip_bucket_termination = true  # Optional, prevent Terragrunt from deleting the bucket on destroy
  }
}