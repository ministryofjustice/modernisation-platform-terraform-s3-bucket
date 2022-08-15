output "bucket" {
  value       = aws_s3_bucket.default
  description = "Direct aws_s3_bucket resource with all attributes"
}

output "bucket_server_side_encryption" {
  value       = aws_s3_bucket_server_side_encryption_configuration.default
  description = "Bucket server-side encryption configuration"
}
