# Modernisation Platform Terraform S3 Bucket Module
[![repo standards badge](https://img.shields.io/badge/dynamic/json?color=blue&style=for-the-badge&logo=github&label=MoJ%20Compliant&query=%24.data%5B%3F%28%40.name%20%3D%3D%20%22modernisation-platform-terraform-s3-bucket%22%29%5D.status&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fgithub_repositories)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/github_repositories#modernisation-platform-terraform-s3-bucket "Link to report")

A Terraform module to standardise S3 buckets with sensible defaults.

## Usage

```
module "s3-bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=v5.0.1"

  bucket_prefix                            = "s3-bucket"
  versioning_enabled                       = false
  
  # Refer to the below section "Replication" before enabling replication
  replication_enabled                      = false
  # Below three variables and providers configuration are only relevant if 'replication_enabled' is set to true
  replication_region                       = "eu-west-2"
  versioning_enabled_on_replication_bucket = false
  replication_role_arn                     = module.s3-bucket-replication-role.role.arn
  providers = {
    # Here we use the default provider Region for replication. Destination buckets can be within the same Region as the
    # source bucket. On the other hand, if you need to enable cross-region replication, please contact the Modernisation
    # Platform team to add a new provider for the additional Region.
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
## Inputs

| Name                                     | Description                                                                           | Type    | Default     | Required    |
|------------------------------------------|---------------------------------------------------------------------------------------|---------|-------------|-------------|
| bucket_prefix                            | Bucket prefix, which will include a randomised suffix to ensure globally unique names | string  | `null`      | no          |
| bucket_name                              | Can be used to set a non-random bucket name, required if not using bucket_prefix      | string  | `null`      | no          |
| acl                                      | Canned ACL to use on the bucket                                                       | string  | `private`   | no          |
| versioning_enabled                       | Enable versioning of the main bucket                                                  | bool    | true        | no          |
| replication_enabled                      | Turn S3 bucket replication on/off                                                     | bool    | false       | no          |
| replication_region                       | Specify region to create the replication bucket                                       | string  | `eu-west-2` | no          |
| versioning_enabled_on_replication_bucket | Enable versioning of the replication bucket                                           | bool    | false       | no          |
| replication_role_arn                     | IAM Role ARN for replication. See below for more information (Required if 'replication enabled' variable is set to true)                                        | string  | ""          | conditional |
| bucket_policy                            | JSON for the bucket policy, see note below                                            | string  | ""          | no          |
| custom_kms_key                           | KMS key ARN to use                                                                    | string  | ""          | no          |
| custom_replication_kms_key               | KMS key ARN to use for replication to eu-west-2                                       | string  | ""          | no          |
| lifecycle_rule                           | Lifecycle rules                                                                       | object  | `null`      | no          |
| log_bucket                               | Bucket for server access logging, if applicable                                       | string  | ""          | no          |
| log_prefix                               | Prefix to use for server access logging, if applicable                                | string  | ""          | no          |
| tags                                     | Tags to apply to resources, where applicable                                          | map     |             | yes         |

## Upgrading from versions below 6.0.0
Version 6.0.0 of this module uses the Hashicorp AWS Provider 4.0 as a minimum.
AWS Provider 4.0 introduces some significant changes to the `s3_bucket` resources as documented [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-4-upgrade).

We have worked to make the change as seamless to your code as possible, but you should expect to update your value for
`Status` from a boolean value of `true | false` to a string value of `Enabled | Disabled`.

## Bucket policies
Regardless of whether a custom bucket policy is set as part of this module, we will always include policy `statement` to require the use of SecureTransport (SSL) for every action on and every resource within the bucket.

## Replication
If replication is enabled then:
- 'custom_replication_kms_key' variable is required, this key must allow access for S3
- 'versioning_enabled' variable must be set to enabled
- 'replication_role_arn' variable must be set to relevant arn for iam role

There are two ways to create the IAM role for replication:
- use the [modernisation-platform-terraform-s3-bucket-replication-role](https://github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket-replication-role) to configure a role based on bucket ARNs
- create one yourself, by following the [Setting up permissions for replication](https://docs.aws.amazon.com/AmazonS3/latest/dev/setting-repl-config-perm-overview.html) guide on AWS

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
