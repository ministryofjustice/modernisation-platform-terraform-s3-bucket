output "bucketArn" {
  value       = module.s3.bucket.arn
  description = "Bucket ARN"
}
output "bucket_id" {
  value       = module.s3.bucket.id
  description = "Bucket Name"
}

output "bucket_awskms" {
  value       = element(module.s3.bucket_server_side_encryption.rule[*].apply_server_side_encryption_by_default[0].sse_algorithm, 0)
  description = "SSE Algorithm"
}

output "bucket_aes256" {
  value       = element(module.s3_with_AES256.bucket_server_side_encryption.rule[*].apply_server_side_encryption_by_default[0].sse_algorithm, 0)
  description = "SSE Algorithm"
}
