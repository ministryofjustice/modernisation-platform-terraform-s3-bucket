# Commented out sections below are the main in unit-test originally
# terraform {
#   required_version = ">= 0.13"
# }

# provider "aws" {
#   access_key                  = "mock_access_key"
#   secret_key                  = "mock_secret_key"
#   region                      = "eu-west-2"
#   s3_force_path_style         = true
#   skip_credentials_validation = true
#   skip_metadata_api_check     = true
#   skip_requesting_account_id  = true

#   endpoints {
#     ec2 = "http://localhost:4566"
#     iam = "http://localhost:4566"
#     s3  = "http://localhost:4566"
#     sts = "http://localhost:4566"
#   }
# }

provider "aws" {
  alias                       = "bucket-replication"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  region                      = "eu-west-2"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    ec2 = "http://localhost:4566"
    iam = "http://localhost:4566"
    s3  = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}

module "s3" {
  source = "../.."
  providers = {
    aws.bucket-replication = aws.bucket-replication
  }
  bucket_prefix        = "s3-bucket"
  replication_role_arn = aws_iam_role.default.arn
  #enable_lifecycle_rules = false
  tags = local.tags
}

# locals {
#   tags = {
#     business-unit = "Platforms"
#     application   = "Modernisation Platform"
#     is-production = true
#     owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
#   }
# }
