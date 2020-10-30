# modernisation-platform-terraform-s3-bucket

A Terraform module to standardise S3 buckets with sensible defaults.

## Usage

```
module "s3-bucket" {
  source               = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket"
  bucket_prefix        = "s3-bucket"
  replication_region   = "eu-west-1"
  replication_role_arn = module.s3-bucket-replication-role.role.arn
  tags                 = local.tags
}
```

## Inputs
| Name                   | Description                                                                           | Type    | Default   | Required |
|------------------------|---------------------------------------------------------------------------------------|---------|-----------|----------|
| acl                    | Canned ACL to use on the bucket                                                       | string  | `private` | no       |
| bucket_policy          | JSON for the bucket policy, see note below                                            | string  | ""        | no       |
| bucket_prefix          | Bucket prefix, which will include a randomised suffix to ensure globally unique names | string  |           | yes      |
| custom_kms_key         | KMS key ARN to use                                                                    | string  | ""        | no       |
| enable_lifecycle_rules | Whether or not to enable standardised lifecycle rules                                 | boolean | false     | no       |
| log_bucket             | Bucket for server access logging, if applicable                                       | string  | ""        | no       |
| log_prefix             | Prefix to use for server access logging, if applicable                                | string  | ""        | no       |
| replication_region     | Region to replicate the main S3 bucket in                                             | string  |           | yes      |
| replication_role_arn   | IAM Role ARN for replication. See below for more information                          | string  |           | yes      |
| tags                   | Tags to apply to resources, where applicable                                          | map     |           | yes      |

## Bucket policies
Regardless of whether a custom bucket policy is set as part of this module, we will always include policy `statement` to require the use of SecureTransport (SSL) for every action on and every resource within the bucket.

## Replication
There are two ways to create the IAM role for replication:
- use the [modernisation-platform-terraform-s3-bucket-replication-role](https://github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket-replication-role) to configure a role based on bucket ARNs
- create one yourself, by following the [Setting up permissions for replication](https://docs.aws.amazon.com/AmazonS3/latest/dev/setting-repl-config-perm-overview.html) guide on AWS

## Outputs
See the [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#attributes-reference) attributes reference. This module outputs the resource map, i.e. `aws_s3_bucket`, so you can access each attribute from Terraform directly under the `bucket` output, e.g. `module.s3-bucket.bucket.id` for the bucket ID.

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
