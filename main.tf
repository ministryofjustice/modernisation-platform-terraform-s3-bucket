data "aws_caller_identity" "current" {}

# Main S3 bucket, that is replicated from (rather than to)
resource "aws_s3_bucket" "default" {
  bucket        = var.bucket_name
  bucket_prefix = var.bucket_prefix

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}

# Configure bucket ACL
resource "aws_s3_bucket_acl" "default" {
  bucket = aws_s3_bucket.default.id
  acl    = var.acl
}

# Configure bucket lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "default" {
  bucket = aws_s3_bucket.default.id

  dynamic "rule" {
    for_each = try(jsondecode(var.lifecycle_rule), var.lifecycle_rule)

    content {
      id     = lookup(rule.value, "id", null)
      prefix = lookup(rule.value, "prefix", null)
      status = lookup(rule.value, "enabled", null)

      abort_incomplete_multipart_upload {
        days_after_initiation = lookup(rule.value, "abort_incomplete_multipart_upload_days", null)
      }

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = length(keys(lookup(rule.value, "expiration", {}))) == 0 ? [] : [lookup(rule.value, "expiration", {})]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = lookup(rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [lookup(rule.value, "noncurrent_version_expiration", {})]

        content {
          noncurrent_days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transition", [])

        content {
          noncurrent_days = lookup(noncurrent_version_transition.value, "days", null)
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }
}

# Configure bucket access logging
resource "aws_s3_bucket_logging" "default" {
  for_each      = (length(var.log_bucket) > 0) ? toset([var.log_bucket]) : []
  bucket        = aws_s3_bucket.default.id
  target_bucket = var.log_bucket
  target_prefix = var.log_prefix
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

  # Create the Public Access Block before the policy is added
  depends_on = [aws_s3_bucket_public_access_block.default]
}

resource "aws_s3_bucket_replication_configuration" "default" {
  for_each = var.replication_enabled ? toset(["run"]) : []
  bucket   = aws_s3_bucket.default.id
  role     = try(var.replication_role_arn, "null")

  rule {
    id       = "default"
    status   = var.replication_enabled ? "Enabled" : "Disabled"
    priority = 0

    destination {
      bucket        = var.replication_enabled ? aws_s3_bucket.replication[0].arn : aws_s3_bucket.replication[0].arn
      storage_class = "STANDARD"
      encryption_configuration {
        replica_kms_key_id = (var.custom_replication_kms_key != "") ? var.custom_replication_kms_key : "arn:aws:kms:${var.replication_region}:${data.aws_caller_identity.current.account_id}:alias/aws/s3"
      }

    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = (var.custom_replication_kms_key != "") ? "Enabled" : ""
      }
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.default.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = (var.custom_kms_key != "") ? "aws:kms" : "AES256"
      kms_master_key_id = (var.custom_kms_key != "") ? var.custom_kms_key : ""
    }
  }
}

resource "aws_s3_bucket_versioning" "default" {
  bucket = aws_s3_bucket.default.id
  versioning_configuration {
    status = (var.versioning_enabled != true) ? "Suspended" : "Enabled"
  }
}

data "aws_iam_policy_document" "default" {
  override_policy_documents = var.bucket_policy

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
  count = var.replication_enabled ? 1 : 0

  provider      = aws.bucket-replication
  bucket        = (var.bucket_name != null) ? "${var.bucket_name}-replication" : null
  bucket_prefix = (var.bucket_prefix != null) ? "${var.bucket_prefix}-replication" : null

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}

# Configure bucket ACL
resource "aws_s3_bucket_acl" "replication" {
  count  = var.replication_enabled ? 1 : 0

  provider      = aws.bucket-replication
  bucket = aws_s3_bucket.replication[count.index].id
  acl    = "private"
}

# Configure bucket lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "replication" {
  count  = var.replication_enabled ? 1 : 0

  provider      = aws.bucket-replication
  bucket = aws_s3_bucket.replication[count.index].id
  rule {
    id     = "main"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 365
      storage_class = "GLACIER"
    }

    expiration {
      days = 730
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 365
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 730
    }
  }
}

# Block public access policies to the replication bucket
resource "aws_s3_bucket_public_access_block" "replication" {
  count = var.replication_enabled ? 1 : 0

  provider                = aws.bucket-replication
  bucket                  = aws_s3_bucket.replication[count.index].bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Attach policies to the S3 bucket
# This ensures every bucket created via this module
# doesn't allow any actions that aren't over SecureTransport methods (i.e. HTTP)
resource "aws_s3_bucket_policy" "replication" {
  count = var.replication_enabled ? 1 : 0

  provider = aws.bucket-replication
  bucket   = aws_s3_bucket.replication[count.index].id
  policy   = data.aws_iam_policy_document.replication[count.index].json

  # Create the Public Access Block before the policy is added
  depends_on = [aws_s3_bucket_public_access_block.replication]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "replication" {
  count  = var.replication_enabled ? 1 : 0

  provider      = aws.bucket-replication
  bucket = aws_s3_bucket.replication[count.index].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = (var.custom_replication_kms_key != "") ? var.custom_replication_kms_key : ""
    }
  }
}

resource "aws_s3_bucket_versioning" "replication" {
  count  = var.replication_enabled ? 1 : 0

  provider      = aws.bucket-replication
  bucket = aws_s3_bucket.replication[count.index].id
  versioning_configuration {
    status = (var.versioning_enabled != true) ? "Suspended" : "Enabled"
  }
}

data "aws_iam_policy_document" "replication" {
  count = var.replication_enabled ? 1 : 0

  statement {
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.replication[count.index].arn,
      "${aws_s3_bucket.replication[count.index].arn}/*"
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
