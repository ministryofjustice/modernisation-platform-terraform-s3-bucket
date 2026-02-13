############################################
# Bucket Naming
############################################

variable "bucket_prefix" {
  type        = string
  description = "Bucket prefix. A random suffix will be added for global uniqueness."
  default     = null

  validation {
    condition     = !(var.bucket_prefix != null && var.bucket_name != null)
    error_message = "Specify either bucket_prefix OR bucket_name — never both."
  }
}

variable "bucket_name" {
  type        = string
  description = "Explicit bucket name. Prefer bucket_prefix for global uniqueness."
  default     = null

  validation {
    condition     = !(var.bucket_prefix != null && var.bucket_name != null)
    error_message = "Specify either bucket_prefix OR bucket_name — never both."
  }
}

############################################
# Core Bucket Settings
############################################

variable "versioning_enabled" {
  type        = bool
  description = "Activate S3 bucket versioning"
  default     = true
}

variable "force_destroy" {
  type        = bool
  description = "Delete all objects when destroying bucket (DANGEROUS)."
  default     = false
}

variable "tags" {
  type        = map(any)
  description = "Tags to apply to resources"
}

############################################
# Replication
############################################

variable "replication_enabled" {
  type        = bool
  description = "Activate S3 replication"
  default     = false

  validation {
    condition     = !(var.replication_enabled && !var.versioning_enabled)
    error_message = "Replication requires versioning_enabled = true."
  }
}

variable "replication_region" {
  type        = string
  description = "Region to create replication bucket"
  default     = "eu-west-2"
}

variable "replication_bucket" {
  type        = string
  description = "Existing bucket for replication. Leave empty to create one."
  default     = ""
}

############################################
# Object Lock (CRITICAL SAFETY)
############################################

variable "replication_object_lock_enabled" {
  type    = bool
  default = false

  validation {
    condition     = !(var.replication_object_lock_enabled && !var.replication_enabled)
    error_message = "Object Lock requires replication_enabled = true."
  }

  validation {
    condition     = !(var.replication_object_lock_enabled && !var.versioning_enabled)
    error_message = "Object Lock requires versioning_enabled = true."
  }

  validation {
    condition     = !(var.replication_object_lock_enabled && var.force_destroy)
    error_message = "force_destroy cannot be true when Object Lock is enabled."
  }
}

variable "replication_object_lock_mode" {
  type    = string
  default = "COMPLIANCE"

  validation {
    condition     = contains(["COMPLIANCE", "GOVERNANCE"], var.replication_object_lock_mode)
    error_message = "Must be COMPLIANCE or GOVERNANCE."
  }
}

variable "replication_object_lock_days" {
  type    = number
  default = 30
}

############################################
# Safety Controls
############################################

variable "replication_prevent_destroy" {
  type        = bool
  default     = true
  description = "Prevents accidental deletion of replication bucket."
}

############################################
# Encryption
############################################

variable "sse_algorithm" {
  type        = string
  default     = "aws:kms"
}

variable "custom_kms_key" {
  type        = string
  default     = ""
}

variable "custom_replication_kms_key" {
  type        = string
  default     = ""
}

############################################
# Ownership / ACL
############################################

variable "acl" {
  type    = string
  default = "private"
}

variable "ownership_controls" {
  type    = string
  default = "ObjectWriter"
}

############################################
# Notifications
############################################

variable "notification_enabled" {
  type    = bool
  default = false
}

variable "notification_sns_arn" {
  type    = string
  default = ""
}

variable "notification_events" {
  type    = list(string)
  default = [""]
}

############################################
# Misc
############################################

variable "suffix_name" {
  type    = string
  default = ""
}

variable "bucket_policy" {
  type    = list(string)
  default = ["{}"]
}

variable "bucket_policy_v2" {
  type    = any
  default = []
}

variable "lifecycle_rule" {
  type = any
  default = []
}
