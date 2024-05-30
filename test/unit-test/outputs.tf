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

output "bucket_notifications" {
  value       = element(module.s3_with_notification.bucket_notifications, 0).bucket
  description = "Retrieve name of bucket with notifications enabled"
}

# output "role_name" {
#   value = module.s3.role[0].name
#   description = "Direct aws_iam_role resource with all attributes"
# }
# output "policy_name" {
#   value = module.s3.policy[0].name
#   description = "Direct aws_iam_policy resource with all attributes"
# }

output "role_name" {
  value = length(module.s3.role) > 0 ? module.s3.role[0].name : ""
  description = "Name of the IAM role for S3 replication"
}

output "policy_name" {
  value = length(module.s3.policy) > 0 ? module.s3.policy[0].name : ""
  description = "Name of the IAM policy for S3 replication"
}
