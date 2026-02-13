############################################
# Locals
############################################

locals {
  replication_bucket_arn = "arn:aws:s3:::${var.replication_bucket}/*"

  # Always generate deterministic + unique bucket names
  replication_bucket_name = var.bucket_name != null ? (
    var.replication_object_lock_enabled
      ? "${var.bucket_name}-replication-locked-${random_id.bucket[0].hex}"
      : "${var.bucket_name}-replication-${random_id.bucket[0].hex}"
  ) : (
    var.replication_object_lock_enabled
      ? "${var.bucket_prefix}-replication-locked-${random_id.bucket[0].hex}"
      : "${var.bucket_prefix}-replication-${random_id.bucket[0].hex}"
  )
}

############################################
# Random suffix (CRITICAL)
############################################

resource "random_id" "bucket" {
  count       = var.replication_enabled ? 1 : 0
  byte_length = 4

  # Forces replacement when object lock state changes
  keepers = {
    bucket_identity = coalesce(var.bucket_name, var.bucket_prefix)
    object_lock     = var.replication_object_lock_enabled
  }
}

data "aws_caller_identity" "current" {}

############################################
# Replication Bucket
############################################

resource "aws_s3_bucket" "replication" {
  count    = var.replication_enabled ? 1 : 0
  provider = aws.bucket-replication

  bucket = local.replication_bucket_name

  force_destroy       = false
  object_lock_enabled = var.replication_object_lock_enabled
  tags                = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

############################################
# Ownership Controls
############################################

resource "aws_s3_bucket_ownership_controls" "replication" {
  count    = var.replication_enabled ? 1 : 0
  provider = aws.bucket-replication
  bucket   = aws_s3_bucket.replication[0].id

  rule {
    object_ownership = var.ownership_controls
  }
}

############################################
# ACL (only if enabled)
############################################

resource "aws_s3_bucket_acl" "replication" {
  count = var.replication_enabled && var.ownership_controls != "BucketOwnerEnforced" ? 1 : 0

  provider   = aws.bucket-replication
  bucket     = aws_s3_bucket.replication[0].id
  acl        = var.acl
  depends_on = [aws_s3_bucket_ownership_controls.replication]
}

############################################
# Versioning (REQUIRED for replication + object lock)
############################################

resource "aws_s3_bucket_versioning" "replication" {
  count    = var.replication_enabled ? 1 : 0
  provider = aws.bucket-replication
  bucket   = aws_s3_bucket.replication[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

############################################
# Encryption
############################################

resource "aws_s3_bucket_server_side_encryption_configuration" "replication" {
  count    = var.replication_enabled ? 1 : 0
  provider = aws.bucket-replication
  bucket   = aws_s3_bucket.replication[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.custom_replication_kms_key != "" ? var.custom_replication_kms_key : null
    }
  }
}

############################################
# Public Access Block
############################################

resource "aws_s3_bucket_public_access_block" "replication" {
  count = var.replication_enabled ? 1 : 0

  provider                = aws.bucket-replication
  bucket                  = aws_s3_bucket.replication[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################################
# Lifecycle
############################################

resource "aws_s3_bucket_lifecycle_configuration" "replication" {
  count    = var.replication_enabled ? 1 : 0
  provider = aws.bucket-replication
  bucket   = aws_s3_bucket.replication[0].id

  rule {
    id     = "main"
    status = "Enabled"

    filter {}

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 365
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 365
      storage_class   = "GLACIER"
    }

    dynamic "expiration" {
      for_each = var.replication_object_lock_enabled ? [] : [1]
      content {
        days = 730
      }
    }
  }
}

############################################
# Object Lock Configuration
############################################

resource "aws_s3_bucket_object_lock_configuration" "replication" {
  count    = var.replication_enabled && var.replication_object_lock_enabled ? 1 : 0
  provider = aws.bucket-replication
  bucket   = aws_s3_bucket.replication[0].id

  rule {
    default_retention {
      mode = var.replication_object_lock_mode
      days = var.replication_object_lock_days
    }
  }

  depends_on = [aws_s3_bucket_versioning.replication]
}

############################################
# IAM Role
############################################

resource "aws_iam_role" "replication_role" {
  count    = var.replication_enabled ? 1 : 0
  provider = aws.bucket-replication

  name               = "AWSS3BucketReplication${var.suffix_name}"
  assume_role_policy = data.aws_iam_policy_document.s3-assume-role-policy.json
  tags               = var.tags
}

data "aws_iam_policy_document" "s3-assume-role-policy" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

############################################
# Replication Policy
############################################

data "aws_iam_policy_document" "replication-policy" {

  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]

    resources = [aws_s3_bucket.default.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectRetention",
      "s3:GetObjectLegalHold"
    ]

    resources = ["${aws_s3_bucket.default.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]

    resources = [aws_s3_bucket.replication[0].arn, "${aws_s3_bucket.replication[0].arn}/*"]
  }
}

resource "aws_iam_policy" "replication_policy" {
  count    = var.replication_enabled ? 1 : 0
  provider = aws.bucket-replication

  name   = "AWSS3BucketReplication${var.suffix_name}"
  policy = data.aws_iam_policy_document.replication-policy.json
}

resource "aws_iam_role_policy_attachment" "replication" {
  count    = var.replication_enabled ? 1 : 0
  provider = aws.bucket-replication

  role       = aws_iam_role.replication_role[0].name
  policy_arn = aws_iam_policy.replication_policy[0].arn
}

############################################
# Replication Rule (Modern / Batch Compatible)
############################################

resource "aws_s3_bucket_replication_configuration" "default" {
  for_each = var.replication_enabled ? toset(["run"]) : []

  bucket = aws_s3_bucket.default.id
  role   = aws_iam_role.replication_role[0].arn

  rule {
    id       = var.replication_object_lock_enabled ? "replication-v2-object-lock" : "replication-v1"
    status   = "Enabled"
    priority = 0

    delete_marker_replication {
      status = "Enabled"
    }

    destination {
      bucket        = aws_s3_bucket.replication[0].arn
      storage_class = "STANDARD"

      encryption_configuration {
        replica_kms_key_id = var.custom_replication_kms_key != "" ?
          var.custom_replication_kms_key :
          "arn:aws:kms:${var.replication_region}:${data.aws_caller_identity.current.account_id}:alias/aws/s3"
      }
    }

    source_selection_criteria {

      replica_modifications {
        status = "Enabled"
      }

      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.default]
}
