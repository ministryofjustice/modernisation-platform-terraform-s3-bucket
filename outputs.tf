output "bucket" {
  value       = aws_s3_bucket.default
  description = "Direct aws_s3_bucket resource with all attributes"
}
output "bucket_id" {
  value = aws_s3_bucket.default
  description = "Bucket name"
}