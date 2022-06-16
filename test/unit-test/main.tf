module "s3" {
  source = "../.."
  providers = {
    aws.bucket-replication = aws
    #   aws.bucket-replication = aws.bucket-replication
  }
  bucket_prefix        = "s3-bucket"
  force_destroy        = true
  replication_role_arn = aws_iam_role.default.arn
  #enable_lifecycle_rules = false
  tags = local.tags
}
