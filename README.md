# modernisation-platform-terraform-s3-bucket

A Terraform module to standardise S3 buckets with sensible defaults.

## Usage

This module inherits the default provider, though you'll need to pass through your replication region. For example, to create the original bucket in eu-west-2, and to replicate it in eu-west-1:

```
provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  alias  = "bucket-replication"
  region = "eu-west-1"
}

module "s3-bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=v3.0.0"

  providers = {
    aws.bucket-replication = aws.eu-west-2
  }
  bucket_prefix        = "s3-bucket"
  replication_role_arn = module.s3-bucket-replication-role.role.arn

  lifecycle_rule = [
    {
      id      = "main"
      enabled = true
      prefix  = ""

      tags = {
        rule      = "log"
        autoclean = "true"
      }

      transition = [
        {
          days          = 60
          storage_class = "STANDARD_IA"
          }, {
          days          = 365
          storage_class = "GLACIER"
        }
      ]

      expiration = {
        days = 2555
      }

      noncurrent_version_transition = [
        {
          days          = 60
          storage_class = "STANDARD_IA"
          }, {
          days          = 365
          storage_class = "GLACIER"
        }
      ]

      noncurrent_version_expiration = {
        days = 2555
      }
    }
  ]

  tags                 = local.tags
}
```

## Inputs

| Name                   | Description                                                                           | Type    | Default   | Required |
|------------------------|---------------------------------------------------------------------------------------|---------|-----------|----------|
| acl                    | Canned ACL to use on the bucket                                                       | string  | `private` | no       |
| bucket_name            | Can be used to set a non-random bucket name, required if not using bucket_prefix      | string  | `null`    | no       |
| bucket_policy          | JSON for the bucket policy, see note below                                            | string  | ""        | no       |
| bucket_prefix          | Bucket prefix, which will include a randomised suffix to ensure globally unique names | string  | `null`    | yes      |
| custom_kms_key         | KMS key ARN to use                                                                    | string  | ""        | no       |
| lifecycle_rule         | Lifecycle rules                                                                       | object  | `null`    | no       |
| log_bucket             | Bucket for server access logging, if applicable                                       | string  | ""        | no       |
| log_prefix             | Prefix to use for server access logging, if applicable                                | string  | ""        | no       |
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
