resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = var.notification_enabled == true ? 1 : 0
  bucket = aws_s3_bucket.default.id

  topic {
    topic_arn = var.notification_sns_arn
    events    = var.notification_events
  }
}

# Main S3 bucket, that is replicated from (rather than to)
# KMS Encryption handled by aws_s3_bucket_server_side_encryption_configuration resource
# Logging handled by aws_s3_bucket_logging resource
# Versioning handled by aws_s3_bucket_versioning resource
# tfsec:ignore:aws-s3-enable-bucket-encryption tfsec:ignore:aws-s3-encryption-customer-key tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "default" {
  #checkov:skip=CKV_AWS_144: "Replication handled in replication configuration resource"
  #checkov:skip=CKV_AWS_18: "Logging handled in logging configuration resource"
  #checkov:skip=CKV_AWS_21: "Versioning handled in Versioning configuration resource"
  #checkov:skip=CKV_AWS_145: "Encryption handled in encryption configuration resource"

  bucket        = var.bucket_name

  bucket_prefix = var.bucket_prefix
  
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_ownership_controls" "default" {

  bucket = aws_s3_bucket.default.id
  rule {
    object_ownership = var.ownership_controls
  }
}

# Configure bucket ACL
resource "aws_s3_bucket_acl" "default" {
  count  = var.ownership_controls == "BucketOwnerEnforced" ? 0 : 1
  bucket = aws_s3_bucket.default.id
  acl    = var.acl
  depends_on = [
    aws_s3_bucket_ownership_controls.default
  ]
}

# Configure bucket lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "default" {
  #checkov:skip=CKV_AWS_300: "Ensure S3 lifecycle configuration sets period for aborting failed uploads"
  bucket = aws_s3_bucket.default.id

  dynamic "rule" {
    for_each = try(jsondecode(var.lifecycle_rule), var.lifecycle_rule)

    content {
      id = lookup(rule.value, "id", null)
      filter {
        prefix = lookup(rule.value, "prefix", null)
      }
      status = lookup(rule.value, "enabled", null)

      abort_incomplete_multipart_upload {
        days_after_initiation = lookup(rule.value, "abort_incomplete_multipart_upload_days", "7")
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
        for_each = length(keys(lookup(rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [
          lookup(rule.value, "noncurrent_version_expiration", {})
        ]

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



# Configure bucket access logging for buckets in the same account
resource "aws_s3_bucket_logging" "default_bucket_object" {
  count = var.log_buckets != null ? 1 : 0

  bucket        = aws_s3_bucket.default.id
  target_bucket = local.log_bucket_name
  target_prefix = var.log_prefix

  dynamic "target_object_key_format" {
    for_each = (var.log_partition_date_source != "None") ? [1] : []
    content {
      partitioned_prefix {
        partition_date_source = var.log_partition_date_source
      }
    }
  }
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
# AWS-provided KMS acceptable compromise in absence of customer provided key
# tfsec:ignore:aws-s3-encryption-customer-key
#tfsec:ignore:avd-aws-0132 S3 encryption should use Custom Managed Keys, KMS is acceptable compromise 
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  #checkov:skip=CKV2_AWS_67: "Ensure AWS S3 bucket encrypted with Customer Managed Key (CMK) has regular rotation"

  bucket = aws_s3_bucket.default.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
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

data "aws_iam_policy_document" "bucket_policy_v2" {
  dynamic "statement" {
    for_each = var.bucket_policy_v2
    content {
      effect  = statement.value.effect
      actions = statement.value.actions
      resources = [
        aws_s3_bucket.default.arn,
        "${aws_s3_bucket.default.arn}/*"
      ]
      dynamic "principals" {
        for_each = statement.value.principals != null ? [statement.value.principals] : []
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }
      dynamic "condition" {
        for_each = statement.value.conditions
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

data "aws_iam_policy_document" "default" {
  override_policy_documents = concat(var.bucket_policy, [data.aws_iam_policy_document.bucket_policy_v2.json])

  statement {
    sid     = "EnforceTLSv12orHigher"
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
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = [1.2]
    }
  }
}


# locally merge the two policies
locals {
  log_bucket_name = var.log_buckets != null ? var.log_buckets["log_bucket_name"] : null
  log_bucket_arn  = var.log_buckets != null ? var.log_buckets["log_bucket_arn"] : null
  new_policy_statements = var.log_buckets != null ? {
    Sid    = "AllowS3Logging"
    Effect = "Allow"
    Principal = {
      Service = "logging.s3.amazonaws.com"
    }
    Action   = "s3:PutObject"
    Resource = "${local.log_bucket_arn}/*"
    Condition = {
      ArnLike = {
        "aws:SourceArn" = aws_s3_bucket.default.arn
      }
    }
  } : null

  updated_policies = var.log_buckets != null ? merge(
    jsondecode(
      coalesce(
        var.log_buckets["log_bucket_policy"],
        jsonencode({
          Version   = "2012-10-17",
          Statement = []
        })
      )
    ),
    {
      Statement = concat(
        jsondecode(
          coalesce(
            var.log_buckets["log_bucket_policy"],
            jsonencode({
              Version   = "2012-10-17",
              Statement = []
            })
          )
        ).Statement,
        [local.new_policy_statements]
      )
    }
  ) : null
}


resource "aws_s3_bucket_policy" "log_bucket_policy" {
  count  = var.log_buckets != null ? 1 : 0
  bucket = local.log_bucket_name
  policy = jsonencode(local.updated_policies)
}


