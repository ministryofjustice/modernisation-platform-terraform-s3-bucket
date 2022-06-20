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

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	bucketArn := terraform.Output(t, terraformOptions, "bucketArn")

	assert.Regexp(t, regexp.MustCompile(`^arn:aws:s3:::s3-bucket-*`), bucketArn)

	bucketName := terraform.Output(t, terraformOptions, "bucketName")
	// 	bucketid := (s3_bucket_id + ".s3.amazonaws.com")
	// 	assert.Regexp(t, regexp.MustCompile(`bucket-name.eu.s3.eu-west-1.amazonaws.com`), bucketName)
}
