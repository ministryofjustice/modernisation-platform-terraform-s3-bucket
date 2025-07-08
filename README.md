# Modernisation Platform Terraform S3 Bucket Module

[![Standards Icon]][Standards Link] [![Format Code Icon]][Format Code Link] [![Scorecards Icon]][Scorecards Link] [![SCA Icon]][SCA Link] [![Terraform SCA Icon]][Terraform SCA Link]

A Terraform module to standardise S3 buckets with sensible defaults.

## Usage

```
module "s3-bucket" {
    source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=v7.0.0"

  bucket_prefix                            = "s3-bucket"
  versioning_enabled                       = true

  # to disable ACLs in preference of BucketOwnership controls as per https://aws.amazon.com/blogs/aws/heads-up-amazon-s3-security-changes-are-coming-in-april-of-2023/ set:
  ownership_controls = "BucketOwnerEnforced"

  # Refer to the below section "Replication" before enabling replication
  replication_enabled                      = false
  # Below variable and providers configuration is only relevant if 'replication_enabled' is set to true
  # replication_region                       = "eu-west-2"
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
    }
  ]

  tags                 = local.tags
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_aws.bucket-replication"></a> [aws.bucket-replication](#provider\_aws.bucket-replication) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.replication_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.replication_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.default_bucket_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_notification.bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_notification.bucket_notification_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_ownership_controls.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_ownership_controls.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.log_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.bucket_policy_v2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.replication-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3-assume-role-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acl"></a> [acl](#input\_acl) | Use canned ACL on the bucket instead of BucketOwnerEnforced ownership controls. var.ownership\_controls must be set to corresponding value below. | `string` | `"private"` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Please use bucket\_prefix instead of bucket\_name to ensure a globally unique name. | `string` | `null` | no |
| <a name="input_bucket_policy"></a> [bucket\_policy](#input\_bucket\_policy) | JSON for the bucket policy | `list(string)` | <pre>[<br/>  "{}"<br/>]</pre> | no |
| <a name="input_bucket_policy_v2"></a> [bucket\_policy\_v2](#input\_bucket\_policy\_v2) | Alternative to bucket\_policy.  Define policies directly without needing to know the bucket ARN | <pre>list(object({<br/>    effect  = string<br/>    actions = list(string)<br/>    principals = optional(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    }))<br/>    conditions = optional(list(object({<br/>      test     = string<br/>      variable = string<br/>      values   = list(string)<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | Bucket prefix, which will include a randomised suffix to ensure globally unique names | `string` | `null` | no |
| <a name="input_custom_kms_key"></a> [custom\_kms\_key](#input\_custom\_kms\_key) | KMS key ARN to use | `string` | `""` | no |
| <a name="input_custom_replication_kms_key"></a> [custom\_replication\_kms\_key](#input\_custom\_replication\_kms\_key) | KMS key ARN to use for replication to eu-west-2 | `string` | `""` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | `bool` | `false` | no |
| <a name="input_lifecycle_rule"></a> [lifecycle\_rule](#input\_lifecycle\_rule) | List of maps containing configuration of object lifecycle management. | `any` | <pre>[<br/>  {<br/>    "enabled": "Enabled",<br/>    "expiration": {<br/>      "days": 730<br/>    },<br/>    "id": "main",<br/>    "noncurrent_version_expiration": {<br/>      "days": 730<br/>    },<br/>    "noncurrent_version_transition": [<br/>      {<br/>        "days": 90,<br/>        "storage_class": "STANDARD_IA"<br/>      },<br/>      {<br/>        "days": 365,<br/>        "storage_class": "GLACIER"<br/>      }<br/>    ],<br/>    "prefix": "",<br/>    "tags": {<br/>      "autoclean": "true",<br/>      "rule": "log"<br/>    },<br/>    "transition": [<br/>      {<br/>        "days": 90,<br/>        "storage_class": "STANDARD_IA"<br/>      },<br/>      {<br/>        "days": 365,<br/>        "storage_class": "GLACIER"<br/>      }<br/>    ]<br/>  }<br/>]</pre> | no |
| <a name="input_log_bucket"></a> [log\_bucket](#input\_log\_bucket) | Unique name of s3 bucket to log to (not defined in terraform) | `string` | `null` | no |
| <a name="input_log_bucket_names"></a> [log\_bucket\_names](#input\_log\_bucket\_names) | Unique names of s3 bucket to log to (not defined in terraform) | `set(string)` | `null` | no |
| <a name="input_log_buckets"></a> [log\_buckets](#input\_log\_buckets) | Map containing log bucket details and its associated bucket policy. | `map(any)` | `null` | no |
| <a name="input_log_partition_date_source"></a> [log\_partition\_date\_source](#input\_log\_partition\_date\_source) | Partition logs by date. Allowed values are 'EventTime', 'DeliveryTime', or 'None'. | `string` | `"None"` | no |
| <a name="input_log_prefix"></a> [log\_prefix](#input\_log\_prefix) | Prefix for all log object keys. | `string` | `null` | no |
| <a name="input_notification_enabled"></a> [notification\_enabled](#input\_notification\_enabled) | Boolean indicating if a notification resource is required for the bucket | `bool` | `false` | no |
| <a name="input_notification_events"></a> [notification\_events](#input\_notification\_events) | The event for which we send topic notifications | `list(string)` | <pre>[<br/>  ""<br/>]</pre> | no |
| <a name="input_notification_queues"></a> [notification\_queues](#input\_notification\_queues) | a map of bucket notification queues where the map key is used as the configuration id | <pre>map(object({<br/>    events        = list(string)     # e.g. ["s3:ObjectCreated:*"]<br/>    filter_prefix = optional(string) # e.g. "images/"<br/>    filter_suffix = optional(string) # e.g. ".gz"<br/>    queue_arn     = string<br/>  }))</pre> | `{}` | no |
| <a name="input_notification_sns_arn"></a> [notification\_sns\_arn](#input\_notification\_sns\_arn) | The arn for the bucket notification SNS topic | `string` | `""` | no |
| <a name="input_ownership_controls"></a> [ownership\_controls](#input\_ownership\_controls) | Bucket Ownership Controls - for use WITH acl var above options are 'BucketOwnerPreferred' or 'ObjectWriter'. To disable ACLs and use new AWS recommended controls set this to 'BucketOwnerEnforced' and which will disabled ACLs and ignore var.acl | `string` | `"ObjectWriter"` | no |
| <a name="input_replication_bucket"></a> [replication\_bucket](#input\_replication\_bucket) | Name of bucket used for replication - if not specified then * will be used in the policy | `string` | `""` | no |
| <a name="input_replication_enabled"></a> [replication\_enabled](#input\_replication\_enabled) | Activate S3 bucket replication | `bool` | `false` | no |
| <a name="input_replication_region"></a> [replication\_region](#input\_replication\_region) | Region to create S3 replication bucket | `string` | `"eu-west-2"` | no |
| <a name="input_replication_role_arn"></a> [replication\_role\_arn](#input\_replication\_role\_arn) | Role ARN to access S3 and replicate objects | `string` | `""` | no |
| <a name="input_sse_algorithm"></a> [sse\_algorithm](#input\_sse\_algorithm) | The server-side encryption algorithm to use | `string` | `"aws:kms"` | no |
| <a name="input_suffix_name"></a> [suffix\_name](#input\_suffix\_name) | Suffix for role and policy names | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources, where applicable | `map(any)` | n/a | yes |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Activate S3 bucket versioning | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket"></a> [bucket](#output\_bucket) | Direct aws\_s3\_bucket resource with all attributes |
| <a name="output_bucket_notifications"></a> [bucket\_notifications](#output\_bucket\_notifications) | n/a |
| <a name="output_bucket_policy"></a> [bucket\_policy](#output\_bucket\_policy) | Policy of the bucket |
| <a name="output_bucket_server_side_encryption"></a> [bucket\_server\_side\_encryption](#output\_bucket\_server\_side\_encryption) | Bucket server-side encryption configuration |
| <a name="output_policy"></a> [policy](#output\_policy) | Direct aws\_iam\_policy resource with all attributes |
| <a name="output_role"></a> [role](#output\_role) | Direct aws\_iam\_role resource with all attributes |
<!-- END_TF_DOCS -->

## Upgrading from versions below 6.0.0

Version 6.0.0 of this module uses the Hashicorp AWS Provider 4.0 as a minimum.
AWS Provider 4.0 introduces some significant changes to the `s3_bucket` resources as documented [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-4-upgrade).

We have worked to make the change as seamless to your code as possible, but you should expect to update your value for
`Status` from a boolean value of `true | false` to a string value of `Enabled | Disabled`.

## Bucket policies

Regardless of whether a custom bucket policy is set as part of this module, we will always include policy `statement` to require the use of SecureTransport (SSL) for every action on and every resource within the bucket.

## Replication

If replication is enabled then:

- Define a provider configuration for the replication region by setting 'aws.bucket-replication' to the desired region e.g.'aws.bucket-replication' = 'aws.replication-region'
- provide either'custom_replication_kms_key' or use default AWS KMS key. The KMS key must be in the same region as the destination bucket and must allow access for S3.
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
