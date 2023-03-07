terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {} # data.aws_region.current.name

locals {
  account_id = data.aws_caller_identity.current.account_id
  region = data.aws_region.current.name
  s3_landing_bucket = "auna-dla${var.env}-landingzone-s3"
  s3_artifacts_bucket = "auna-dla${var.env}-artifacts-s3"
}
