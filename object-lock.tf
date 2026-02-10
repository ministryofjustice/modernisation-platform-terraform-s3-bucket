resource "aws_s3_bucket_object_lock_configuration" "this" {
  count  = var.object_lock_enabled && var.object_lock_days > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  object_lock_configuration {
    object_lock_enabled = "Enabled"

    rule {
      default_retention {
        mode = var.object_lock_mode
        days = var.object_lock_days
      }
    }
  }
}
