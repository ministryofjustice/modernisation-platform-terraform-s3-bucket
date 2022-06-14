variable "acl" {
  type        = string
  description = "Canned ACL to use on the bucket"
  default     = "private"
}

variable "versioning_enabled" {
  type        = bool
  description = "Activate S3 bucket versioning"
  default     = true
}

variable "replication_enabled" {
  type        = bool
  description = "Activate S3 bucket replication"
  default     = false
}

variable "replication_region" {
  type        = string
  description = "Region to create S3 replication bucket"
  default     = "eu-west-2"
}

variable "versioning_enabled_on_replication_bucket" {
  type        = bool
  description = "Activate S3 bucket versioning on replication bucket"
  default     = false
}

variable "bucket_policy" {
  type        = list(string)
  description = "JSON for the bucket policy"
  default     = ["{}"]
}

variable "bucket_prefix" {
  type        = string
  description = "Bucket prefix, which will include a randomised suffix to ensure globally unique names"
  default     = null
}

variable "bucket_name" {
  type        = string
  description = "Please use bucket_prefix instead of bucket_name to ensure a globally unique name."
  default     = null
}

variable "custom_kms_key" {
  type        = string
  description = "KMS key ARN to use"
  default     = ""
}

variable "custom_replication_kms_key" {
  type        = string
  description = "KMS key ARN to use for replication to eu-west-2"
  default     = ""
}

variable "lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default = [{
    id      = "main"
    enabled = "Enabled"
    prefix  = ""
    tags = {
      rule      = "log"
      autoclean = "true"
    }
    transition = [
      {
        days          = 90
        storage_class = "STANDARD_IA"
        }, {
        days          = 365
        storage_class = "GLACIER"
      }
    ]
    expiration = {
      days = 730
    }
    noncurrent_version_transition = [
      {
        days          = 90
        storage_class = "STANDARD_IA"
        }, {
        days          = 365
        storage_class = "GLACIER"
      }
    ]
    noncurrent_version_expiration = {
      days = 730
    }
  }]
}

variable "log_bucket" {
  type        = string
  description = "Bucket for server access logging, if applicable"
  default     = ""
}

variable "log_prefix" {
  type        = string
  description = "Prefix to use for server access logging, if applicable"
  default     = ""
}

variable "replication_role_arn" {
  type        = string
  description = "Role ARN to access S3 and replicate objects"
  default     = ""
}

variable "tags" {
  type        = map(any)
  description = "Tags to apply to resources, where applicable"
}

variable "force_destroy" {
  type        = bool
  description = "A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = false
}
