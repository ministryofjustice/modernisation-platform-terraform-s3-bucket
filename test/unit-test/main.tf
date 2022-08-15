module "s3" {
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
