resource "aws_s3_bucket" "default" {
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

resource "aws_s3_bucket_public_access_block" "default" {
  bucket                  = aws_s3_bucket.default.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

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
