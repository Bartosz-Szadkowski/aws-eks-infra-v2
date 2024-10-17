include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/iam"
}

dependency "s3" {
  config_path = "../s3"
  mock_outputs = {
    bucket_arn = "arn:aws:s3:::application-bucket-esta-v1"
  }
}

inputs = {
  python_web_app_s3_bucket_arn = dependency.s3.outputs.bucket_arn
}