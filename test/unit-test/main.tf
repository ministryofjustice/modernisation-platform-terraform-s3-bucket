module "s3" {
  #checkov:skip=CKV_AWS_300: "Ensure S3 lifecycle configuration sets period for aborting failed uploads - This is not needed in our tests"
  source = "../.."
  providers = {
    aws.bucket-replication = aws
  }
  bucket_prefix       = "unit-test-bucket"
  force_destroy       = true
  tags                = local.tags
  replication_enabled = false
}

module "s3_with_AES256" {
  source = "../.."
  providers = {
    aws.bucket-replication = aws
  }
  bucket_prefix = "unit-test-bucket"
  force_destroy = true
  sse_algorithm = "AES256"
  tags          = local.tags
}

data "aws_iam_policy_document" "topic" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = ["arn:aws:sns:*:*:s3-event-notification-topic"]

  }
}

#AWS managed KMS key is fine for unit tests
#tfsec:ignore:aws-sns-topic-encryption-use-cmk
resource "aws_sns_topic" "topic" {
  name              = "s3-event-notification-topic"
  kms_master_key_id = "alias/aws/sns"
  policy            = data.aws_iam_policy_document.topic.json
}

module "s3_with_notification" {
  #checkov:skip=CKV_AWS_300: "Ensure S3 lifecycle configuration sets period for aborting failed uploads - This is not needed in our tests"
  source = "../.."
  providers = {
    aws.bucket-replication = aws
  }
  bucket_prefix        = "unit-test-bucket"
  force_destroy        = true
  notification_enabled = true
  notification_events  = ["s3:ObjectCreated:*"]
  notification_sns_arn = aws_sns_topic.topic.arn
  tags                 = local.tags
}

data "aws_caller_identity" "current" {}

# KMS Source
resource "aws_kms_key" "kms_primary_s3" {
  description = "kms_primary_s3"
  # policy                  = data.aws_iam_policy_document.kms_policy_s3.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
}
resource "aws_kms_alias" "kms_primary_alias" {
  name          = "alias/kms_primary_alias"
  target_key_id = aws_kms_key.kms_primary_s3.id
}
data "aws_iam_policy_document" "kms_policy_s3" {

  # checkov:skip=CKV_AWS_111: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_356: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_109: "role is resticted by limited actions in member account"

  statement {
    sid    = "Allow management access of the key to the logging account"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
  statement {
    sid    = "Allow use of the key including encryption"
    effect = "Allow"
    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Encrypt*",
      "kms:Describe*",
      "kms:Decrypt*"
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
  }
}