variable "acl" {
  type        = string
  description = "Canned ACL to use on the bucket"
  default     = "private"
}

variable "replication_enabled" {
  
  type = bool
  description = "Activate S3 bucket replication"
  default = false
}

variable "bucket_policy" {
  type        = string
  description = "JSON for the bucket policy"
  default     = "{}"
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

variable "lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
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
}

variable "tags" {
  type        = map(any)
  description = "Tags to apply to resources, where applicable"
}
