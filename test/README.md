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
