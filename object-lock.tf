resource "aws_s3_bucket_object_lock_configuration" "default" {
  count  = var.object_lock_enabled && var.object_lock_days > 0 ? 1 : 0
  bucket = aws_s3_bucket.default.id

  depends_on = [
    aws_s3_bucket_versioning.default
  ]

  rule {
    default_retention {
      mode = var.object_lock_mode
      days = var.object_lock_days
    }
  }
}
