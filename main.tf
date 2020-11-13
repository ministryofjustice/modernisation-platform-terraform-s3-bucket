# The default calling provider is inherited here, so we only need to create
# a new one for the replicated region.
provider "aws" {
  alias = "bucket-replication"
}

# Main S3 bucket, that is replicated from (rather than to)
resource "aws_s3_bucket" "default" {
  bucket        = var.bucket_name
  bucket_prefix = var.bucket_prefix
  acl           = var.acl

  lifecycle {
    prevent_destroy = true
  }

  dynamic lifecycle_rule {
    for_each = var.enable_lifecycle_rules ? [var.enable_lifecycle_rules] : []

    content {
      enabled = var.enable_lifecycle_rules

      noncurrent_version_transition {
        days          = 30
        storage_class = "GLACIER"
      }

      transition {
        days          = 30
        storage_class = "GLACIER"
      }
    }
  }

  dynamic logging {
    for_each = (length(var.log_bucket) > 0) ? [var.log_bucket] : []

    content {
      target_bucket = var.log_bucket
      target_prefix = var.log_prefix
    }
  }

  replication_configuration {
    role = var.replication_role_arn

    rules {
      id       = "enabled"
      status   = "Enabled"
      priority = 0

      destination {
        bucket        = aws_s3_bucket.replication.arn
        storage_class = "STANDARD"
      }
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = (length(var.custom_kms_key) > 0) ? var.custom_kms_key : ""
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = var.tags
}

# Block public access policies for this bucket
resource "aws_s3_bucket_public_access_block" "default" {
  bucket                  = aws_s3_bucket.default.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Merge and attach policies to the S3 bucket
# This ensures every bucket created via this module
# doesn't allow any actions that aren't over SecureTransport methods (i.e. HTTP)
resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.default.id
  policy = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  override_json = var.bucket_policy

  statement {
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.default.arn,
      "${aws_s3_bucket.default.arn}/*"
    ]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

# Replication S3 bucket, to replicate to (rather than from)
resource "aws_s3_bucket" "replication" {
  provider      = aws.bucket-replication
  bucket        = (var.bucket_name != null) ? "${var.bucket_name}-replication" : null
  bucket_prefix = (var.bucket_prefix != null) ? "${var.bucket_prefix}-replication" : null
  acl           = "private"

  lifecycle {
    prevent_destroy = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = (length(var.custom_kms_key) > 0) ? var.custom_kms_key : ""
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = var.tags
}

# Block public access policies to the replication bucket
resource "aws_s3_bucket_public_access_block" "replication" {
  provider                = aws.bucket-replication
  bucket                  = aws_s3_bucket.replication.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Attach policies to the S3 bucket
# This ensures every bucket created via this module
# doesn't allow any actions that aren't over SecureTransport methods (i.e. HTTP)
resource "aws_s3_bucket_policy" "replication" {
  provider = aws.bucket-replication
  bucket   = aws_s3_bucket.replication.id
  policy   = data.aws_iam_policy_document.replication.json
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.replication.arn,
      "${aws_s3_bucket.replication.arn}/*"
    ]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
