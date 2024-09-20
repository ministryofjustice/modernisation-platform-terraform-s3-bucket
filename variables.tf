variable "acl" {
  type        = string
  description = "Use canned ACL on the bucket instead of BucketOwnerEnforced ownership controls. var.ownership_controls must be set to corresponding value below."
  default     = "private"
}

variable "ownership_controls" {
  type        = string
  description = "Bucket Ownership Controls - for use WITH acl var above options are 'BucketOwnerPreferred' or 'ObjectWriter'. To disable ACLs and use new AWS recommended controls set this to 'BucketOwnerEnforced' and which will disabled ACLs and ignore var.acl"
  default     = "ObjectWriter"
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

variable "bucket_policy" {
  type        = list(string)
  description = "JSON for the bucket policy"
  default     = ["{}"]
}

variable "bucket_policy_v2" {
  type = list(object({
    effect  = string
    actions = list(string)
    principals = optional(object({
      type        = string
      identifiers = list(string)
    }))
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  description = "Alternative to bucket_policy.  Define policies directly without needing to know the bucket ARN"
  default     = []
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

variable "log_buckets" {
  type        = map(any)
  description = "Map containing log bucket details and its associated bucket policy."
  default     = null
  nullable    = true
}
variable "log_bucket" {
  type        = string
  description = "Unique name of s3 bucket to log to (not defined in terraform)"
  default     = null
  nullable    = true
}

variable "log_bucket_names" {
  type        = set(string)
  description = "Unique names of s3 bucket to log to (not defined in terraform)"
  default     = null
  nullable    = true
}

variable "log_partition_date_source" {
  type        = string
  default     = "None"
  description = "Partition logs by date. Allowed values are 'EventTime', 'DeliveryTime', or 'None'."

  validation {
    condition     = contains(["EventTime", "DeliveryTime", "None"], var.log_partition_date_source)
    error_message = "log_partition_date_source must be either 'EventTime', 'DeliveryTime', or 'None'."
  }
}

variable "log_prefix" {
  type        = string
  description = "Prefix for all log object keys."
  default     = null
  nullable    = true
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

variable "sse_algorithm" {
  type        = string
  description = "The server-side encryption algorithm to use"
  default     = "aws:kms"
}

variable "notification_sns_arn" {
  type        = string
  description = "The arn for the bucket notification SNS topic"
  default     = ""
}

variable "notification_enabled" {
  type        = bool
  description = "Boolean indicating if a notification resource is required for the bucket"
  default     = false
}

variable "notification_events" {
  type        = list(string)
  description = "The event for which we send notifications"
  default     = [""]
}
variable "suffix_name" {
  type        = string
  default     = ""
  description = "Suffix for role and policy names"
}
variable "replication_bucket" {
  type        = string
  description = "Name of bucket used for replication - if not specified then * will be used in the policy"
  default     = ""
}
