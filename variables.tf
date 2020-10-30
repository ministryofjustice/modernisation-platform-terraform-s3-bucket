variable "acl" {
  type        = string
  description = "Canned ACL to use on the bucket"
  default     = "private"
}

variable "bucket_policy" {
  type        = string
  description = "JSON for the bucket policy"
  default     = ""
}

variable "bucket_prefix" {
  type        = string
  description = "Bucket prefix, which will include a randomised suffix to ensure globally unique names"
}

variable "custom_kms_key" {
  type        = string
  description = "KMS key ARN to use"
  default     = ""
}

variable "enable_lifecycle_rules" {
  type        = bool
  description = "Whether or not to enable standardised lifecycle rules"
  default     = false
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

variable "replication_region" {
  type        = string
  description = "Region to replicate the S3 bucket to"
}

variable "replication_role_arn" {
  type        = string
  description = "Role ARN to access S3 and replicate objects"
}

variable "tags" {
  type        = map
  description = "Tags to apply to resources, where applicable"
}
