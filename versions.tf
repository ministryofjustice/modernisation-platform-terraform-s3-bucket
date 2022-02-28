terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0.0, < 5.0.0"
      configuration_aliases = [aws.bucket-replication]
    }
  }
  required_version = ">= 1.0.1"
}

# The default calling provider is inherited here, so we only need to create
# a new one for the replicated region
