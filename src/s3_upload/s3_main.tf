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
  profile                  = "default"
}

locals {
  s3_landing_bucket = "auna-dla${var.env}-landingzone-s3"
  xlsx_files = ["PLATAFORMAS", "OBJETIVOS_NIVEL"]
}

/* Objeto para subir xlsx a S3 */
resource "aws_s3_object" "upload_xlsx_file" {
  for_each = toset(local.xlsx_files)
  bucket = "${local.s3_landing_bucket}"
  key = "Modama/dashboard_canales/telemarketing/${each.value}.xlsx"
  source = "data/telemarketing/${each.value}.xlsx"
}