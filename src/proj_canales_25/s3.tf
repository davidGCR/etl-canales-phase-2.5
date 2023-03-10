/* S3 carpeta telemarketing*/
resource "aws_s3_object" "tlmk_folder"{
  bucket = "${local.s3_landing_bucket}"
  key = "Modama/dashboard_canales/telemarketing/"
}


# locals {
#   libs = ["openpyxl.zip"]
# }

/* S3 carpeta libs*/
# resource "aws_s3_object" "libs_folder"{
#   bucket = "${local.s3_landing_bucket}"
#   key = "structured-data/OLAP/Modama/Dashboard_Canales/"
# }

/* Objeto para subir lib a S3 */
# resource "aws_s3_object" "upload_lib_file" {
#   for_each = toset(local.libs)
#   bucket = "${local.s3_artifacts_bucket}"
#   key = "structured-data/OLAP/Modama/Dashboard_Canales/${each.value}"
#   source = "../lib/${each.value}"
# }