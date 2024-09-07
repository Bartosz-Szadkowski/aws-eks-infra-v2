resource "aws_s3_bucket" "application_bucket" {
  bucket = var.bucket_name
  force_destroy = true
  tags   = var.tags
  }

  # Public access block to prevent accidental exposure
  resource "aws_s3_bucket_public_access_block" "application_bucket_public_access" {
    bucket = aws_s3_bucket.my_bucket.id
    block_public_acls   = true
    block_public_policy = true
    ignore_public_acls  = true
    restrict_public_buckets = true
  }

resource "aws_s3_bucket_versioning" "application_bucket_versioning" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_eks" {
  bucket = aws_s3_bucket.example.id
  policy = data.aws_iam_policy_document.allow_access_from_eks.json
}

data "aws_iam_policy_document" "allow_access_from_eks" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["123456789012"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.example.arn,
      "${aws_s3_bucket.example.arn}/*",
    ]
  }
}

