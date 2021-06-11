# https://foghornconsulting.com/2020/11/13/terraform-aws-provider-3-14-0-regression/
terraform {
  required_version = ">= 0.14.7, < 0.14.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0,!= 3.14.0"
    }
  }
}

provider "aws" {
  profile = "john"
  region  = "eu-west-1"
}

locals {
  bucket-a-name = "genomics-platform-engineer-test-bucket-a"
  bucket-b-name = "genomics-platform-engineer-test-bucket-b"
}
