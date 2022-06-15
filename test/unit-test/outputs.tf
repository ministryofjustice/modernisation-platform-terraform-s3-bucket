output "aws_s3_bucket" {
  value       = module.s3.aws_s3_bucket.id
  description = "Direct aws_s3_bucket resource with all attributes"
}
