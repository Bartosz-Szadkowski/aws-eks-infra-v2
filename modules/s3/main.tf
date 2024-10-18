resource "aws_s3_bucket" "application_bucket" {
  bucket        = var.bucket_prefix
  force_destroy = true
  tags          = var.tags
}

# Public access block to prevent accidental exposure
resource "aws_s3_bucket_public_access_block" "application_bucket_public_access" {
  bucket                  = aws_s3_bucket.application_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "application_bucket_versioning" {
  bucket = aws_s3_bucket.application_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "application_bucket_policy" {
  bucket = aws_s3_bucket.application_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "s3:*"
        Resource = [
          "${aws_s3_bucket_application_bucket_versioning.arn}",
          "${aws_s3_bucket.application_bucket_versioning.arn}/*" # Object level actions
        ]
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/python-web-app-pod-role"
        }
      }
    ]
  })
}

