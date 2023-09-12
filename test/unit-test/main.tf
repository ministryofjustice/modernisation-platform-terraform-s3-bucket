module "s3" {
# This is not needed in our tests
  #checkov:skip=CKV_AWS_300: "Ensure S3 lifecycle configuration sets period for aborting failed uploads"
  source = "../.."
  providers = {
    aws.bucket-replication = aws
  }
  bucket_prefix = "s3-bucket"
  force_destroy = true
  tags          = local.tags
}

module "s3_with_AES256" {
  source = "../.."
  providers = {
    aws.bucket-replication = aws
  }
  bucket_prefix = "s3-bucket"
  force_destroy = true
  sse_algorithm = "AES256"
  tags          = local.tags
}
