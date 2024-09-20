module "s3" {
  #checkov:skip=CKV_AWS_300: "Ensure S3 lifecycle configuration sets period for aborting failed uploads - This is not needed in our tests"
  source = "../.."
  providers = {
    aws.bucket-replication = aws
  }
  bucket_prefix = "unit-test-bucket"
  force_destroy = true
  tags          = local.tags
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

#trivy:ignore:AVD-AWS-0086
#trivy:ignore:AVD-AWS-0087
#trivy:ignore:AVD-AWS-0088
#trivy:ignore:AVD-AWS-0090
#trivy:ignore:AVD-AWS-0091
#trivy:ignore:AVD-AWS-0093
#trivy:ignore:AVD-AWS-0094
#trivy:ignore:AVD-AWS-0132
resource "aws_s3_bucket" "non-modulised-bucket" {
  #checkov:skip=CKV2_AWS_6: "Ensure that S3 bucket has a Public Access block - This is not needed in our tests"
  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled - This is not needed in our tests"
  #checkov:skip=CKV_AWS_21: "Ensure all data stored in the S3 bucket have versioning enabled - This is not needed in our tests"
  #checkov:skip=CKV2_AWS_61: "Ensure that an S3 bucket has a lifecycle configuration - This is not needed in our tests"
  #checkov:skip=CKV2_AWS_62: "Ensure S3 buckets should have event notifications enabled - This is not needed in our tests"
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled - This is not needed in our tests"
  #checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default - This is not needed in our tests"
  bucket = "log-test-bucket-051683332738327"
}

#trivy:ignore:AVD-AWS-0086
#trivy:ignore:AVD-AWS-0087
#trivy:ignore:AVD-AWS-0088
#trivy:ignore:AVD-AWS-0090
#trivy:ignore:AVD-AWS-0091
#trivy:ignore:AVD-AWS-0093
#trivy:ignore:AVD-AWS-0094
#trivy:ignore:AVD-AWS-0132
resource "aws_s3_bucket" "non-modulised-bucket-2" {
  #checkov:skip=CKV2_AWS_6: "Ensure that S3 bucket has a Public Access block - This is not needed in our tests"
  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled - This is not needed in our tests"
  #checkov:skip=CKV_AWS_21: "Ensure all data stored in the S3 bucket have versioning enabled - This is not needed in our tests"
  #checkov:skip=CKV2_AWS_61: "Ensure that an S3 bucket has a lifecycle configuration - This is not needed in our tests"
  #checkov:skip=CKV2_AWS_62: "Ensure S3 buckets should have event notifications enabled - This is not needed in our tests"
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled - This is not needed in our tests"
  #checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default - This is not needed in our tests"

  bucket = "log-test-bucket-2-051683332738327"
}

module "dummy_s3_log_bucket" {
  #checkov:skip=CKV_AWS_300: "Ensure S3 lifecycle configuration sets period for aborting failed uploads - This is not needed in our tests"
  source = "../.."
  providers = {
    aws.bucket-replication = aws
  }
  bucket_prefix = "unit-test-log-bucket"
  force_destroy = true
  tags          = local.tags
}

module "s3_with_log_bucket" {
  #checkov:skip=CKV_AWS_300: "Ensure S3 lifecycle configuration sets period for aborting failed uploads - This is not needed in our tests"
  source = "../.."
  providers = {
    aws.bucket-replication = aws
  }
  bucket_prefix = "unit-test-bucket-with-logs"
  force_destroy = true
  log_buckets   = tomap({ "log_bucket" : module.dummy_s3_log_bucket.bucket, "log_bucket_policy" : module.dummy_s3_log_bucket.bucket_policy })
  log_prefix    = "logs/"
  tags          = local.tags
}

data "aws_caller_identity" "current" {}
