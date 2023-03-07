/* Objeto para subir job script 1 (.py) en S3 */
resource "aws_s3_object" "upload_glue_script_1" {
  bucket = "aws-glue-assets-${local.account_id}-${local.region}"
  key = "scripts/${var.script_name_1}"
  source = "jobs/${var.script_name_1}"
  etag = filemd5("jobs/${var.script_name_1}")
}

resource "aws_glue_job" "glue_job_25_1" {
  name     = replace("${var.script_name_1}", ".py", "")
  role_arn = "arn:aws:iam::${local.account_id}:role/auna-dl-${var.env}-full-role"
  command {
    script_location = "s3://aws-glue-assets-${local.account_id}-${local.region}/scripts/${var.script_name_1}"
  }
  glue_version      = var.glue_version
  max_retries       = var.max_retries
  timeout           = var.job_timeout
  number_of_workers = var.number_of_workers
  worker_type       = var.worker_type
  default_arguments = {
    "--job-language"        = "python"
    "--job-bookmark-option" = "job-bookmark-disable"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics" = "true"
    "--enable-spark-ui" = "true"
    # "--spark-event-logs-path": "s3://aws-glue-assets-${local.account_id}-${local.region}/sparkHistoryLogs/"
    "--extra-py-files" = "s3://auna-dla${var.env}-artifacts-s3/structured-data/OLAP/Modama/Dashboard_Canales/openpyxl.zip"
    "--TempDir" = "s3://aws-glue-assets-${local.account_id}-${local.region}/temporary/"
    # "--s3_landing_bucket" = "auna-dla${var.env}-raw-s3"
    # "--s3_mkf_path" = "structured-data/OLAP/dwh-gestionsalud/pry-gs-marketforceintermedio/xls_mkf_v2/"
    # "--s3_sar_path" = "structured-data/OLAP/dwh-gestionsalud/pry-gs-marketforceintermedio/xls_sar_v2/"
  }
}