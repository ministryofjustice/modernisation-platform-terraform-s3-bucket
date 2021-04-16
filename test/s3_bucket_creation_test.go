package main

import (
	"regexp"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestS3Creation(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./unit-test",
	})

	// Would fail as lifecycle.prevent_destroy is set on the bucket
	//defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	bucketArn := terraform.Output(t, terraformOptions, "bucket_arn")
	bucketName := terraform.Output(t, terraformOptions, "bucket_name")

	assert.Regexp(t, regexp.MustCompile(`^arn:aws:s3:::s3-bucket-*`), bucketArn)
	assert.Regexp(t, regexp.MustCompile(`^s3-bucket-*`), bucketName)
}
