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


/* resource "aws_dynamodb_table_item" "plataformas_schema" {
  table_name = "auna-dl-${var.env}-storage-dsbcanales-dyndb-v1-audit-1"
  hash_key = "name"
  range_key = "folder"
  item = file("./data/plataformas.json")
}  */


locals {
  json_files = ["PLATAFORMAS.json", "OBJETIVOS_NIVEL.json"]
}

resource "aws_dynamodb_table_item" "plataformas_schema" {
  for_each   = toset(local.json_files)
  table_name = "auna-dl-${var.env}-storage-dsbcanales-dyndb-v1-audit-1"
  hash_key   = "name"
  range_key  = "folder"
  item       = file("./data/${each.value}")
}
