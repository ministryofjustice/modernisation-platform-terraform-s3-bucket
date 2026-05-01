# Modernisation Platform Terraform S3 Bucket Module

[![Standards Icon]][Standards Link] [![Format Code Icon]][Format Code Link] [![Scorecards Icon]][Scorecards Link] [![SCA Icon]][SCA Link] [![Terraform SCA Icon]][Terraform SCA Link]

A Terraform module to standardise S3 buckets with sensible defaults.

## Usage

```
module "s3-bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=v10.0.0"

  bucket_prefix      = "s3-bucket"
  versioning_enabled = true

  # to disable ACLs in preference of BucketOwnership controls as per https://aws.amazon.com/blogs/aws/heads-up-amazon-s3-security-changes-are-coming-in-april-of-2023/ set:
  ownership_controls = "BucketOwnerEnforced"

  # Refer to the below section "Replication" before enabling replication
  replication_enabled = false
  # Below variable and providers configuration is only relevant if 'replication_enabled' is set to true
  # replication_region  = "eu-west-2"
  providers = {
    # Here we use the default provider Region for replication. Destination buckets can be within the same Region as the
    # source bucket. On the other hand, if you need to enable cross-region replication, please contact the Modernisation
    # Platform team to add a new provider for the additional Region.
    # Leave this provider block in even if you are not using replication
    aws.bucket-replication = aws
  }

  lifecycle_rule = [
    {
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
        },
        {
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
        },
        {
          days          = 365
          storage_class = "GLACIER"
        }
      ]

      noncurrent_version_expiration = {
        days = 730
      }
    }
  ]

  # Default/recommended encryption mode
  sse_algorithm = "aws:kms"
  custom_kms_key       = "arn:aws:kms:eu-west-2:123456789012:key/your-key-id"
  # Optional compatibility mode for services that cannot use SSE-KMS
  # sse_algorithm = "AES256"
  tags = local.tags
}
```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 6.0  |

## Providers

| Name                                                                                                      | Version |
| --------------------------------------------------------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)                                                          | ~> 6.0  |
| <a name="provider_aws.bucket-replication"></a> [aws.bucket-replication](#provider_aws.bucket-replication) | ~> 6.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                           | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_policy.replication_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                                    | resource    |
| [aws_iam_role.replication_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                                          | resource    |
| [aws_iam_role_policy_attachment.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                                           | resource    |
| [aws_s3_bucket.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                                 | resource    |
| [aws_s3_bucket.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                             | resource    |
| [aws_s3_bucket_acl.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl)                                                                         | resource    |
| [aws_s3_bucket_acl.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl)                                                                     | resource    |
| [aws_s3_bucket_lifecycle_configuration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration)                                 | resource    |
| [aws_s3_bucket_lifecycle_configuration.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration)                             | resource    |
| [aws_s3_bucket_logging.default_bucket_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging)                                                   | resource    |
| [aws_s3_bucket_notification.bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification)                                           | resource    |
| [aws_s3_bucket_notification.bucket_notification_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification)                               | resource    |
| [aws_s3_bucket_object_lock_configuration.s3_bucket_object_lock_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration) | resource    |
| [aws_s3_bucket_ownership_controls.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls)                                           | resource    |
| [aws_s3_bucket_ownership_controls.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls)                                       | resource    |
| [aws_s3_bucket_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                                                                   | resource    |
| [aws_s3_bucket_policy.log_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                                                         | resource    |
| [aws_s3_bucket_policy.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                                                               | resource    |
| [aws_s3_bucket_public_access_block.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)                                         | resource    |
| [aws_s3_bucket_public_access_block.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)                                     | resource    |
| [aws_s3_bucket_replication_configuration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration)                             | resource    |
| [aws_s3_bucket_server_side_encryption_configuration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration)       | resource    |
| [aws_s3_bucket_server_side_encryption_configuration.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration)   | resource    |
| [aws_s3_bucket_versioning.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                                           | resource    |
| [aws_s3_bucket_versioning.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                                       | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                                                  | data source |
| [aws_iam_policy_document.bucket_policy_v2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                                 | data source |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                                          | data source |
| [aws_iam_policy_document.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                                      | data source |
| [aws_iam_policy_document.replication-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                               | data source |
| [aws_iam_policy_document.s3-assume-role-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                            | data source |

## Inputs

| Name                                                                                                            | Description                                                                                                                                                                                                                                         | Type                                                                                                                                                                                                                                                                                                           | Default                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | Required |
| --------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_acl"></a> [acl](#input_acl)                                                                      | Use canned ACL on the bucket instead of BucketOwnerEnforced ownership controls. var.ownership_controls must be set to corresponding value below.                                                                                                    | `string`                                                                                                                                                                                                                                                                                                       | `"private"`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |    no    |
| <a name="input_bucket_name"></a> [bucket_name](#input_bucket_name)                                              | Please use bucket_prefix instead of bucket_name to ensure a globally unique name.                                                                                                                                                                   | `string`                                                                                                                                                                                                                                                                                                       | `null`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |    no    |
| <a name="input_bucket_policy"></a> [bucket_policy](#input_bucket_policy)                                        | JSON for the bucket policy                                                                                                                                                                                                                          | `list(string)`                                                                                                                                                                                                                                                                                                 | <pre>[<br/> "{}"<br/>]</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |    no    |
| <a name="input_bucket_policy_v2"></a> [bucket_policy_v2](#input_bucket_policy_v2)                               | Alternative to bucket_policy. Define policies directly without needing to know the bucket ARN                                                                                                                                                       | <pre>list(object({<br/> effect = string<br/> actions = list(string)<br/> principals = optional(object({<br/> type = string<br/> identifiers = list(string)<br/> }))<br/> conditions = optional(list(object({<br/> test = string<br/> variable = string<br/> values = list(string)<br/> })), [])<br/> }))</pre> | `[]`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |    no    |
| <a name="input_bucket_prefix"></a> [bucket_prefix](#input_bucket_prefix)                                        | Bucket prefix, which will include a randomised suffix to ensure globally unique names                                                                                                                                                               | `string`                                                                                                                                                                                                                                                                                                       | `null`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |    no    |
| <a name="input_custom_kms_key"></a> [custom_kms_key](#input_custom_kms_key)                                     | Customer-managed KMS key ARN to use for bucket encryption. Required when encryption_algorithm is aws:kms                                                                                                                                            | `string`                                                                                                                                                                                                                                                                                                       | `""`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |    no    |
| <a name="input_custom_replication_kms_key"></a> [custom_replication_kms_key](#input_custom_replication_kms_key) | Customer-managed KMS key ARN to use for replication destination bucket encryption                                                                                                                                                                   | `string`                                                                                                                                                                                                                                                                                                       | `""`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |    no    |
| <a name="input_force_destroy"></a> [force_destroy](#input_force_destroy)                                        | A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable.                                                         | `bool`                                                                                                                                                                                                                                                                                                         | `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |    no    |
| <a name="input_lifecycle_rule"></a> [lifecycle_rule](#input_lifecycle_rule)                                     | List of maps containing configuration of object lifecycle management.                                                                                                                                                                               | `any`                                                                                                                                                                                                                                                                                                          | <pre>[<br/> {<br/> "enabled": "Enabled",<br/> "expiration": {<br/> "days": 730<br/> },<br/> "id": "main",<br/> "noncurrent_version_expiration": {<br/> "days": 730<br/> },<br/> "noncurrent_version_transition": [<br/> {<br/> "days": 90,<br/> "storage_class": "STANDARD_IA"<br/> },<br/> {<br/> "days": 365,<br/> "storage_class": "GLACIER"<br/> }<br/> ],<br/> "prefix": "",<br/> "tags": {<br/> "autoclean": "true",<br/> "rule": "log"<br/> },<br/> "transition": [<br/> {<br/> "days": 90,<br/> "storage_class": "STANDARD_IA"<br/> },<br/> {<br/> "days": 365,<br/> "storage_class": "GLACIER"<br/> }<br/> ]<br/> }<br/>]</pre> |    no    |
| <a name="input_log_bucket"></a> [log_bucket](#input_log_bucket)                                                 | Unique name of s3 bucket to log to (not defined in terraform)                                                                                                                                                                                       | `string`                                                                                                                                                                                                                                                                                                       | `null`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |    no    |
| <a name="input_log_bucket_names"></a> [log_bucket_names](#input_log_bucket_names)                               | Unique names of s3 bucket to log to (not defined in terraform)                                                                                                                                                                                      | `set(string)`                                                                                                                                                                                                                                                                                                  | `null`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |    no    |
| <a name="input_log_buckets"></a> [log_buckets](#input_log_buckets)                                              | Map containing log bucket details and its associated bucket policy.                                                                                                                                                                                 | `map(any)`                                                                                                                                                                                                                                                                                                     | `null`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |    no    |
| <a name="input_log_partition_date_source"></a> [log_partition_date_source](#input_log_partition_date_source)    | Partition logs by date. Allowed values are 'EventTime', 'DeliveryTime', or 'None'.                                                                                                                                                                  | `string`                                                                                                                                                                                                                                                                                                       | `"None"`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |    no    |
| <a name="input_log_prefix"></a> [log_prefix](#input_log_prefix)                                                 | Prefix for all log object keys.                                                                                                                                                                                                                     | `string`                                                                                                                                                                                                                                                                                                       | `null`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |    no    |
| <a name="input_notification_enabled"></a> [notification_enabled](#input_notification_enabled)                   | Boolean indicating if a notification resource is required for the bucket                                                                                                                                                                            | `bool`                                                                                                                                                                                                                                                                                                         | `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |    no    |
| <a name="input_notification_events"></a> [notification_events](#input_notification_events)                      | The event for which we send topic notifications                                                                                                                                                                                                     | `list(string)`                                                                                                                                                                                                                                                                                                 | <pre>[<br/> ""<br/>]</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |    no    |
| <a name="input_notification_queues"></a> [notification_queues](#input_notification_queues)                      | a map of bucket notification queues where the map key is used as the configuration id                                                                                                                                                               | <pre>map(object({<br/> events = list(string) # e.g. ["s3:ObjectCreated:*"]<br/> filter_prefix = optional(string) # e.g. "images/"<br/> filter_suffix = optional(string) # e.g. ".gz"<br/> queue_arn = string<br/> }))</pre>                                                                                    | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |    no    |
| <a name="input_notification_sns_arn"></a> [notification_sns_arn](#input_notification_sns_arn)                   | The arn for the bucket notification SNS topic                                                                                                                                                                                                       | `string`                                                                                                                                                                                                                                                                                                       | `""`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |    no    |
| <a name="input_object_lock_days"></a> [object_lock_days](#input_object_lock_days)                               | The number of days that you want to specify for the default retention period                                                                                                                                                                        | `number`                                                                                                                                                                                                                                                                                                       | `null`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |    no    |
| <a name="input_ownership_controls"></a> [ownership_controls](#input_ownership_controls)                         | Bucket Ownership Controls - for use WITH acl var above options are 'BucketOwnerPreferred' or 'ObjectWriter'. To disable ACLs and use new AWS recommended controls set this to 'BucketOwnerEnforced' and which will disabled ACLs and ignore var.acl | `string`                                                                                                                                                                                                                                                                                                       | `"ObjectWriter"`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |    no    |
| <a name="input_replication_bucket"></a> [replication_bucket](#input_replication_bucket)                         | Name of bucket used for replication - if not specified then \* will be used in the policy                                                                                                                                                           | `string`                                                                                                                                                                                                                                                                                                       | `""`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |    no    |
| <a name="input_replication_enabled"></a> [replication_enabled](#input_replication_enabled)                      | Activate S3 bucket replication                                                                                                                                                                                                                      | `bool`                                                                                                                                                                                                                                                                                                         | `false`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |    no    |
| <a name="input_replication_region"></a> [replication_region](#input_replication_region)                         | Region to create S3 replication bucket                                                                                                                                                                                                              | `string`                                                                                                                                                                                                                                                                                                       | `"eu-west-2"`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |    no    |
| <a name="input_replication_role_arn"></a> [replication_role_arn](#input_replication_role_arn)                   | Role ARN to access S3 and replicate objects                                                                                                                                                                                                         | `string`                                                                                                                                                                                                                                                                                                       | `""`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |    no    |
| <a name="input_sse_algorithm"></a> [sse_algorithm](#input_sse_algorithm)                                        | The server-side encryption algorithm to use                                                                                                                                                                                                         | `string`                                                                                                                                                                                                                                                                                                       | `"aws:kms"`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |    no    |
| <a name="input_suffix_name"></a> [suffix_name](#input_suffix_name)                                              | Suffix for role and policy names                                                                                                                                                                                                                    | `string`                                                                                                                                                                                                                                                                                                       | `""`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                   | Tags to apply to resources, where applicable                                                                                                                                                                                                        | `map(any)`                                                                                                                                                                                                                                                                                                     | n/a                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |   yes    |
| <a name="input_versioning_enabled"></a> [versioning_enabled](#input_versioning_enabled)                         | Activate S3 bucket versioning                                                                                                                                                                                                                       | `bool`                                                                                                                                                                                                                                                                                                         | `true`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |    no    |

## Outputs

| Name                                                                                                                       | Description                                        |
| -------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| <a name="output_bucket"></a> [bucket](#output_bucket)                                                                      | Direct aws_s3_bucket resource with all attributes  |
| <a name="output_bucket_notifications"></a> [bucket_notifications](#output_bucket_notifications)                            | n/a                                                |
| <a name="output_bucket_policy"></a> [bucket_policy](#output_bucket_policy)                                                 | Policy of the bucket                               |
| <a name="output_bucket_server_side_encryption"></a> [bucket_server_side_encryption](#output_bucket_server_side_encryption) | Bucket server-side encryption configuration        |
| <a name="output_policy"></a> [policy](#output_policy)                                                                      | Direct aws_iam_policy resource with all attributes |
| <a name="output_role"></a> [role](#output_role)                                                                            | Direct aws_iam_role resource with all attributes   |

<!-- END_TF_DOCS -->

## Upgrading from versions below 6.0.0

Version 6.0.0 of this module uses the Hashicorp AWS Provider 4.0 as a minimum.
AWS Provider 4.0 introduces some significant changes to the `s3_bucket` resources as documented [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-4-upgrade).

We have worked to make the change as seamless to your code as possible, but you should expect to update your value for
`Status` from a boolean value of `true | false` to a string value of `Enabled | Disabled`.

## ⚠️ Breaking changes (v10.0.0)

- Default encryption is now **SSE-KMS (`aws:kms`)**
- `custom_kms_key` is required when using KMS encryption
- Bucket policies now enforce encryption headers on uploads
- Uploads without correct headers will be denied (`AccessDenied`)
- AES256 is no longer the default, but can be explicitly enabled

If you are upgrading from a previous version:

- Ensure all uploading services support SSE-KMS headers
- Or explicitly switch to `sse_algorithm = "AES256"` where required
  Otherwise, Terraform will fail during planning due to enforced encryption requirements.

## Bucket policies

Regardless of whether a custom bucket policy is set as part of this module, we will always include policy `statement` to require the use of SecureTransport (SSL) for every action on and every resource within the bucket.

### Encryption requirements

This module supports configurable server-side encryption.

---

### Default (recommended)

- `sse_algorithm = "aws:kms"`
- Customer-managed KMS keys (SSE-KMS) are used

---

### KMS encryption (`aws:kms`)

When using KMS encryption:

- `custom_kms_key` **must be provided**
- AWS-managed KMS keys (e.g. `alias/aws/s3`) are not supported
- Bucket policies enforce:
  - encryption must be enabled
  - only `aws:kms` is allowed
  - the correct KMS key must be used
  - uploads must explicitly include SSE-KMS headers

#### Required upload headers:

- `x-amz-server-side-encryption: aws:kms`
- `x-amz-server-side-encryption-aws-kms-key-id: <custom_kms_key>`

#### Uploads will be denied if they:

- omit server-side encryption headers
- use `AES256`
- use `aws:kms` with a different KMS key

> ⚠️ Some AWS services (e.g. CloudTrail, ELB access logs, AWS Config) may not send these headers by default.  
> These services must be configured to use your KMS key, otherwise uploads will fail with `AccessDenied`.

---

### AES256 encryption (`AES256`)

You may opt out of KMS enforcement:

```hcl
sse_algorithm = "AES256"
```

When using AES256:

- KMS-specific bucket policy enforcement is disabled
- No custom key is required
- This can be used for AWS services that cannot use SSE-KMS

### When should I use AES256?

Use AES256 only if you cannot use SSE-KMS.

This is typically required when:

- using AWS-managed services that do not support customer-managed KMS keys
  (e.g. some logging destinations such as ELB/ALB access logs, CloudFront logs, or legacy integrations)

If you encounter `AccessDenied` errors when uploading to the bucket,
and the service cannot be configured to use your KMS key,
switch to:

```hcl
sse_algorithm = "AES256"
```

Otherwise, KMS (aws:kms) should always be preferred.

## Replication

If replication is enabled then:

- Define a provider configuration for the replication region by setting 'aws.bucket-replication' to the desired region e.g.'aws.bucket-replication' = 'aws.replication-region'
- provide `custom_replication_kms_key` when using KMS encryption. AWS-managed KMS keys are not supported. The key must be in the same region as the destination bucket and must allow access for S3.
- if using `sse_algorithm = "AES256"`, replication does not require a custom KMS key
- 'versioning_enabled' variable must be set to enabled. Both source and destination buckets must have versioning enabled.
- 'replication_region' variable must be set to desired destination region.
- 'ownership_controls' variable must be set to 'BucketOwnerEnforced' for full control of all objects in the bucket and to disable ACLs.

There are two ways to create the IAM role for replication:

- use the [modernisation-platform-terraform-s3-bucket](https://github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket) to configure a role based on bucket ARNs.
- create one yourself, by following the [Setting up permissions for replication](https://docs.aws.amazon.com/AmazonS3/latest/dev/setting-repl-config-perm-overview.html) guide on AWS.

## Outputs

See the [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#attributes-reference) attributes reference. This module outputs the resource map, i.e. `aws_s3_bucket`, so you can access each attribute from Terraform directly under the `bucket` output, e.g. `module.s3-bucket.bucket.id` for the bucket ID.

## Looking for issues?

If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

## S3 bucket versioning notes

**S3 is not suitable to store application logs directly but is ok for archived logs**

- S3 is a bad idea for log files, since you cannot append to an object in S3. For every line in the log you'd have to download the file, append it and upload again, or make a new S3 object for every line in the log, which is highly inefficient. User data that doesn't change too often (like only a couple times a day or less) makes sense in S3. Something that changes all the time might make more sense in a database (stored on EBS).
- If you want to send logs directly to S3, you generate log files locally and save them to S3 periodically. For instance rotate your log files every minute and then send the old ones to S3.

**Every version is charged as an individual object**

- Normal Amazon S3 rates apply for every version of an object stored and transferred. Each version of an object is the entire object; it is not just a diff from the previous version. Thus, if you have three versions of an object stored, you are charged for three objects.

**Versioning allows recovering files that are accidentally deleted**

- With versioning you can recover more easily from both unintended user actions and application failures. Versioning-enabled buckets can help you recover objects from accidental deletion or overwrite. For example, if you delete an object, Amazon S3 inserts a delete marker instead of removing the object permanently. If you overwrite an object, it results in a new object version in the bucket. After you version-enable a bucket, it can never return to an unversioned state. But you can suspend versioning on that bucket.

**Versioning requires separate lifecycle management configuration**

- If you have versioning enabled, then in addition to the lifecycle policy for the current version you will need to configure a lifecycle policy for noncurrent versions. Otherwise, older versions will never be moved to cheaper storage and will never be expired/deleted.

**References**

1. [Using versioning in S3 buckets](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html)
2. https://serverfault.com/questions/116011/aws-where-should-we-store-images-css-and-log-files-of-the-application
3. https://www.quora.com/What-is-the-best-way-to-send-application-logs-directly-to-S3
4. [How S3 Versioning works](https://docs.aws.amazon.com/AmazonS3/latest/userguide/versioning-workflows.html)

[Standards Link]: https://github-community.service.justice.gov.uk/repository-standards/modernisation-platform-terraform-s3-bucket "Repo standards badge."
[Standards Icon]: https://github-community.service.justice.gov.uk/repository-standards/api/modernisation-platform-terraform-s3-bucket/badge
[Format Code Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-s3-bucket/format-code.yml?labelColor=231f20&style=for-the-badge&label=Formate%20Code
[Format Code Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket/actions/workflows/format-code.yml
[Scorecards Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-s3-bucket/scorecards.yml?branch=main&labelColor=231f20&style=for-the-badge&label=Scorecards
[Scorecards Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket/actions/workflows/scorecards.yml
[SCA Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-s3-bucket/code-scanning.yml?branch=main&labelColor=231f20&style=for-the-badge&label=Secure%20Code%20Analysis
[SCA Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket/actions/workflows/code-scanning.yml
[Terraform SCA Icon]: https://img.shields.io/github/actions/workflow/status/ministryofjustice/modernisation-platform-terraform-s3-bucket/code-scanning.yml?branch=main&labelColor=231f20&style=for-the-badge&label=Terraform%20Static%20Code%20Analysis
[Terraform SCA Link]: https://github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket/actions/workflows/terraform-static-analysis.yml
