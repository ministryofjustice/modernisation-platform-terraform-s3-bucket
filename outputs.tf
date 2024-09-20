output "bucket" {
  value       = aws_s3_bucket.default
  description = "Direct aws_s3_bucket resource with all attributes"
}

output "bucket_notifications" {
  value = [for i in aws_s3_bucket_notification.bucket_notification : i]
}

output "bucket_server_side_encryption" {
  value       = aws_s3_bucket_server_side_encryption_configuration.default
  description = "Bucket server-side encryption configuration"
}

output "policy" {
  value       = aws_iam_policy.replication_policy
  description = "Direct aws_iam_policy resource with all attributes"
}
output "role" {
  value       = aws_iam_role.replication_role
  description = "Direct aws_iam_role resource with all attributes"
}
output "bucket_policy" {
  value       = aws_s3_bucket_policy.default
  description = "Policy of the bucket"
}

