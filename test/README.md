# Terratest Unit Tests

## Initialisation

On first set up of a new repository, run:

```
go mod init github.com/ministryofjustice/<repo-name>
```

Then run:

```
go mod tidy
```

# How to run the tests locally

Run the tests from within the `test` directory using the `testing-test` user credentials.

Get the credentials from https://moj.awsapps.com selecting the testing-test AWS account.

Copy the credentials and export them by pasting them into the terminal from which you will run the tests.

Next go into the testing folder and run the tests.

```
cd test
go mod download
go test -v
```

⚠️ Note:

- This module defaults to SSE-KMS (`aws:kms`)
- `custom_kms_key` must be provided when using the default KMS mode
- AES256 is still supported, but only as an explicit opt-in (`sse_algorithm = "AES256"`) for compatibility scenarios
- If replication is enabled with KMS, `custom_replication_kms_key` must also be provided

The customer-managed KMS key policy must allow the principals uploading to the bucket to use the key (e.g. `kms:Encrypt`, `kms:Decrypt`, `kms:GenerateDataKey`, `kms:DescribeKey`).
If replication is enabled with KMS, the destination KMS key must also allow access for the replication role and S3 replication service.
By default, in KMS mode, uploads must explicitly include SSE-KMS headers:

- `x-amz-server-side-encryption: aws:kms`
- `x-amz-server-side-encryption-aws-kms-key-id: <custom_kms_key>`
Uploads that omit these headers, use AES256, or use a different KMS key will be denied.

For compatibility scenarios where clients rely on bucket default SSE-KMS encryption instead of explicit request headers, you can disable strict request-header enforcement:

```hcl
enforce_kms_request_headers = false
```

> `enforce_kms_request_headers` only applies when `sse_algorithm = "aws:kms"`.
> When using `AES256`, KMS request-header enforcement is not used and this setting has no effect.

### AWS service principals (built-in exemptions)

AWS service principals are automatically exempt from KMS header enforcement. This is implemented via a `aws:PrincipalType` condition that only applies the header requirements to `AWS` type principals.

This built-in exemption means:

- **ELB/ALB access logs** (via `delivery.logs.amazonaws.com` service principal) can write directly without KMS headers
- **CloudWatch Logs** (via service principal) can write directly without KMS headers
- **Other AWS services** using service principals can write without header requirements
- **IAM principals** (users, roles, accounts) must still send explicit KMS headers when `enforce_kms_request_headers = true`

This is particularly useful for integrations like the [modernisation-platform-terraform-loadbalancer](https://github.com/ministryofjustice/modernisation-platform-terraform-loadbalancer) module, which uses `delivery.logs.amazonaws.com` service principal to write ALB access logs directly to your S3 bucket.

When this mode is enabled:

- Objects are still encrypted at rest using the configured customer-managed KMS key
- S3 applies bucket default encryption automatically (`Default_SSE_KMS`)
- Upload clients are not required to send SSE-KMS request headers
- This is useful for compatibility with AWS-managed services and legacy uploaders that do not explicitly send SSE-KMS headers

Upon successful run, you should see an output similar to the below

```
TestS3Creation 2024-05-13T16:46:58+01:00 logger.go:66: Destroy complete! Resources: 37 destroyed.
TestS3Creation 2024-05-13T16:46:58+01:00 logger.go:66:
--- PASS: TestS3Creation (69.46s)
PASS
ok  	github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket	69.837s

```

## References

1. https://terratest.gruntwork.io/docs/getting-started/quick-start/
2. https://github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket/blob/main/.github/workflows/go-terratest.yml
