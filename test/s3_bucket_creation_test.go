package main

import (
	"regexp"
	"testing"

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

	assert.Regexp(t, regexp.MustCompile(`^arn:aws:s3:::s3-bucket-*`), bucketArn)
	// Verify that our Bucket has a policy attached
	aws.AssertS3BucketPolicyExists(t, awsRegion, bucketID)

	// Verify that our Bucket has versioning enabled
	actualStatus := aws.GetS3BucketVersioning(t, awsRegion, bucketID)
	expectedStatus := "Enabled"
	assert.Equal(t, expectedStatus, actualStatus)

	// Verify bucket notification is created
	//bucketNotification := terraform.Output(t, terraformOptions, "bucket_notification")
	//if bucketNotification != "" {
	//		fmt.Println("OK")
	//} else {fmt.Println("NOOOO")}
}
