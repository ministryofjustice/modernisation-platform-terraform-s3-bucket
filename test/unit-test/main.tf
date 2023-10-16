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
resource "aws_sns_topic" "topic" {
  #checkov:skip=CKV_AWS_26: "Encryption not required as topic only available during test run"
  name   = "s3-event-notification-topic"
  policy = data.aws_iam_policy_document.topic.json
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