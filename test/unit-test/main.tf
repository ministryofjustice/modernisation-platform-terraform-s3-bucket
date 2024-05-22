module "s3" {
  #checkov:skip=CKV_AWS_300: "Ensure S3 lifecycle configuration sets period for aborting failed uploads - This is not needed in our tests"
  source = "../.."
  providers = {
    aws.bucket-replication = aws
  }
  bucket_prefix       = "unit-test-bucket"
  force_destroy       = true
  tags                = local.tags
  replication_enabled = true
  # versioning_enabled  = true
  ownership_controls  = "BucketOwnerPreferred"
}

#    lifecycle_rule = [
#     {
#       id      = "main"
#       enabled = "Enabled"
#       tags    = {}
#       transition = [
#         {
#           days          = 90
#           storage_class = "STANDARD_IA"
#           }, {
#           days          = 365
#           storage_class = "GLACIER"
#         }
#       ]
#       expiration = {
#         days = 730
#       }
#       noncurrent_version_transition = [
#         {
#           days          = 90
#           storage_class = "STANDARD_IA"
#           }, {
#           days          = 365
#           storage_class = "GLACIER"
#         }
#       ]
#       noncurrent_version_expiration = {
#         days = 730
#       }
#     }
#   ]


# }


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

