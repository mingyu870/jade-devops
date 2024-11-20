terraform {
  required_version = ">= 1.8.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.42"
    }
    awscc = {
      source                = "hashicorp/awscc"
      version               = "~> 0.75.0"
      configuration_aliases = [awscc.cc]
    }
  }
}
