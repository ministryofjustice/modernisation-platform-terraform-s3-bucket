output "bucketArn" {
  value       = module.s3.bucket.arn
  description = "Bucket ARN"
}
output "bucket_id" {
  value       = module.s3.bucket.id
  description = "Bucket Name"
}
