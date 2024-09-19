package main

import (
	"regexp"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestS3Creation(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./unit-test",
	})

	defer terraform.Destroy(t, terraformOptions)
	awsRegion := "eu-west-2"
	terraform.InitAndApply(t, terraformOptions)

	bucketArn := terraform.Output(t, terraformOptions, "bucketArn")
	// Run `terraform output` to get the value of an output variable
	bucketID := terraform.Output(t, terraformOptions, "bucket_id")

	// Check aws:kms as default
	bucketAWSKMS := terraform.Output(t, terraformOptions, "bucket_awskms")
	assert.Regexp(t, regexp.MustCompile(`aws:kms`), bucketAWSKMS)

	// Check AES256 possible
	bucketAES256 := terraform.Output(t, terraformOptions, "bucket_aes256")
	assert.Regexp(t, regexp.MustCompile(`AES256`), bucketAES256)

	assert.Regexp(t, regexp.MustCompile(`arn:aws:s3:::unit-test-bucket*`), bucketArn)
	// Verify that our Bucket has a policy attached
	aws.AssertS3BucketPolicyExists(t, awsRegion, bucketID)

	// Verify that our Bucket has versioning enabled
	actualStatus := aws.GetS3BucketVersioning(t, awsRegion, bucketID)
	expectedStatus := "Enabled"
	assert.Equal(t, expectedStatus, actualStatus)

	// Verify that a bucket notification outputs a bucket name
	bucketNotification := terraform.Output(t, terraformOptions, "bucket_notifications")
	assert.Regexp(t, regexp.MustCompile(`unit-test-bucket*`), bucketNotification)

	// roleName := terraform.Output(t, terraformOptions, "role_name")
	// assert.Regexp(t, regexp.MustCompile(`^AWSS3BucketReplication*`), roleName)

	// policyName := terraform.Output(t, terraformOptions, "policy_name")
	// assert.Regexp(t, regexp.MustCompile(`^AWSS3BucketReplicationPolicy*`), policyName)

	// Retrieve the role_name output
	roleName := terraform.Output(t, terraformOptions, "role_name")

	// Retrieve the policy_name output
	policyName := terraform.Output(t, terraformOptions, "policy_name")

	// Check if role name and policy name are empty, which indicates replication is disabled
	if roleName == "" && policyName == "" {
		// Replication is not enabled, assert that the role name and policy name are empty
		assert.Equal(t, "", roleName, "Role name should be empty when replication is not enabled.")
		assert.Equal(t, "", policyName, "Policy name should be empty when replication is not enabled.")
	} else {
		// Replication is enabled, assert that the role name and policy name match the expected patterns
		assert.Regexp(t, regexp.MustCompile("^AWSS3BucketReplication*"), roleName)
		assert.Regexp(t, regexp.MustCompile("^AWSS3BucketReplication.*"), policyName)
	}
}

func TestS3Logging(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./unit-test",
	})

	// Ensure that resources are cleaned up at the end of the test
	defer terraform.Destroy(t, terraformOptions)
	awsRegion := "eu-west-2"
	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Retrieve the source bucket and log bucket from the output
    sourceBucket := terraform.Output(t, terraformOptions, "log_source_bucket")
    logBucketName := terraform.Output(t, terraformOptions, "log_bucket_name")

	// Retrieve the name of the log bucket target of source bucket
	sourceLogBucketName := aws.GetS3BucketLoggingTarget(t, "eu-west-2", sourceBucket)

	// Verify that names are the same
	assert.Equal(sourceLogBucketName, logBucketName, "Log bucket should contain log")
}
