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
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	terraform.InitAndApply(t, terraformOptions)

	bucketArn := terraform.Output(t, terraformOptions, "bucketArn")
	// Run `terraform output` to get the value of an output variable
	bucketID := terraform.Output(t, terraformOptions, "bucket_id")

	assert.Regexp(t, regexp.MustCompile(`^arn:aws:s3:::s3-bucket-*`), bucketArn)
	// Verify that our Bucket has a policy attached
	aws.AssertS3BucketPolicyExists(t, awsRegion, bucketID)
}
