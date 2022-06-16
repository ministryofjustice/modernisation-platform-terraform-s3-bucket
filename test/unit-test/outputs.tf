output "bucketArn" {
  value       = module.s3.bucket.arn
  description = "Bucket ARN"
}
output "bucketname" {
  value       = module.s3.bucket.id
  description = "Bucket Name"
}