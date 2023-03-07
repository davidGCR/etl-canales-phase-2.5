provider "archive" {}
data "archive_file" "zip" {
  type        = "zip"
  source_file = "lambda_validator/lambda_function.py"
  output_path = "lambda_validator/lambda_function.zip"
}
resource "aws_lambda_function" "lambda" {
  /* source = "terraform-aws-modules/lambda/aws" */
  function_name = "auna-dl-qa-prueba-file-validator_v2"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  description   = "schema validator for dsh-canales"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  role = "arn:aws:iam::${local.account_id}:role/auna-dl-${var.env}-pre_update-lambda"
  timeout = 180
  layers = ["arn:aws:lambda:${local.region}:336392948345:layer:AWSSDKPandas-Python39:4"]
}

resource "aws_lambda_permission" "allow_bucket_landing" {
  statement_id  = "AllowExecutionFromS3BucketLanding"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::auna-dla${var.env}-landingzone-s3"
}

# Adding S3 bucket as trigger to my lambda and giving the permissions
resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = "auna-dla${var.env}-landingzone-s3"
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix = "Modama/dashboard_canales/"
    filter_suffix = ".csv"

  }
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix = "Modama/dashboard_canales/"
    filter_suffix = ".xlsx"
  }
  depends_on = [
    aws_lambda_permission.allow_bucket_landing
  ]
}
output "lambda" {
  value = aws_lambda_function.lambda.qualified_arn
}