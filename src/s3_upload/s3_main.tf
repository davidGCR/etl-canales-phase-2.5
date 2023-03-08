terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region                   = "us-east-1"
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  # profile                  = "default"
  profile                  = "${terraform.workspace}"
}

locals {
  environments = {
    qa = "auna-qa"
    dev = "daviduser"
  }
  only_in_qa_mapping = {
    daviduser    = 0
    auna-qa      = 1
  }
  only_in_qa = "${local.only_in_qa_mapping[terraform.workspace]}"

  only_in_dev_mapping = {
    daviduser    = 1
    auna-qa      = 0
  }
  only_in_dev = "${local.only_in_dev_mapping[terraform.workspace]}"

  s3_landing_bucket = "${terraform.workspace == local.environments.qa ? "auna-dla${var.env}-landingzone-s3" : "landing-test-0"}"
  key_qa = "Modama/dashboard_canales/telemarketing"
  key_dev = "telemarketing"
  folder_key = "${terraform.workspace == local.environments.qa ? "${local.key_qa}" : "${local.key_dev}"}"
  xlsx_files = ["PLATAFORMAS", "OBJETIVOS_NIVEL"]
}

/* Objeto para subir xlsx a S3 */
resource "aws_s3_object" "upload_xlsx_file" {
  # for_each = terraform.workspace=="auna-qa" ? toset(local.xlsx_files) : []
  for_each = toset(local.xlsx_files)
  bucket = "${local.s3_landing_bucket}"
  key = "${local.folder_key}/${each.value}.xlsx"
  source = "data/telemarketing/${each.value}.xlsx"
}


# Bucket landing para pruebasen cuenta diferente
resource "aws_s3_bucket" "landing_test" {
  count = local.only_in_dev # crear solo en dev
  bucket = "${local.s3_landing_bucket}"
  tags = {
    Project = "Canales25-${terraform.workspace}"
  }
}

resource "aws_s3_bucket_acl" "landing_test_acl"{
  count = local.only_in_dev # crear solo en dev
  bucket = aws_s3_bucket.landing_test[0].id
  acl    = "private"
}