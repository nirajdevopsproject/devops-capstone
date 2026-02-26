# Provider for Primary Region
provider "aws" {
  region = var.primary_region
}
# Provider for DR Region
provider "aws" {
  alias  = "dr"
  region = var.dr_region
}
# S3 Bucket (Primary)
resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket_name
  force_destroy = true
}
# Enable Versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}
# Enable Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
# DynamoDB Table (State Locking)
resource "aws_dynamodb_table" "lock_table" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
# Cross Region State Replication
# DR S3 Bucket
resource "aws_s3_bucket" "tf_state_dr" {
  provider = aws.dr
  bucket   = "${var.bucket_name}-dr"
}
# Versioning for DR Bucket
resource "aws_s3_bucket_versioning" "versioning_dr" {
  provider = aws.dr
  bucket   = aws_s3_bucket.tf_state_dr.id

  versioning_configuration {
    status = "Enabled"
  }
}
# Replication Role
resource "aws_iam_role" "replication" {
  name = "tf-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_role_policy" "replication_policy" {
  name = "tf-replication-policy"
  role = aws_iam_role.replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.tf_state.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl"
        ]
        Resource = [
          "${aws_s3_bucket.tf_state.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete"
        ]
        Resource = [
          "${aws_s3_bucket.tf_state_dr.arn}/*"
        ]
      }
    ]
  })
}
# Replication Configuration
resource "aws_s3_bucket_replication_configuration" "replication" {

  bucket = aws_s3_bucket.tf_state.id
  role   = aws_iam_role.replication.arn

  depends_on = [
    aws_s3_bucket_versioning.versioning,
    aws_s3_bucket_versioning.versioning_dr
  ]

  rule {
    id     = "replicate-state"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.tf_state_dr.arn
      storage_class = "STANDARD"
    }
  }
}