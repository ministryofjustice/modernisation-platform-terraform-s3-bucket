# S3 bucket replication: role
resource "aws_iam_role" "default" {
  name               = "AWSS3BucketReplication"
  assume_role_policy = data.aws_iam_policy_document.s3-assume-role-policy.json
}

# S3 bucket replication: assume role policy
data "aws_iam_policy_document" "s3-assume-role-policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "default" {
  name   = "AWSS3BucketReplicationPolicy"
  policy = data.aws_iam_policy_document.default-policy.json
}

# S3 bucket replication: role policy
data "aws_iam_policy_document" "default-policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:ReplicateObject",
      "s3:ReplicateDelete"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}
