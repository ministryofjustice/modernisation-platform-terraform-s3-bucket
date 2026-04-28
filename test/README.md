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
- This module now enforces SSE-KMS only (`aws:kms`)
- `custom_kms_key` must be provided
- AES256 is no longer supported
- If replication is enabled, `custom_replication_kms_key` must also be provided

- The customer-managed KMS key policy must allow the principals uploading to the bucket to use the key (e.g. `kms:Encrypt`, `kms:Decrypt`, `kms:GenerateDataKey`, `kms:DescribeKey`)
- If replication is enabled, the destination KMS key must also allow access for the replication role and S3 replication service

- Uploads must explicitly include SSE-KMS headers:
  - `x-amz-server-side-encryption: aws:kms`
  - `x-amz-server-side-encryption-aws-kms-key-id: <custom_kms_key>`
- Uploads that omit these headers, use AES256, or use a different KMS key will be denied (even if bucket default encryption is enabled)

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