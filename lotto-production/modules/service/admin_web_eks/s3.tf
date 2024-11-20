resource "aws_s3_object" "dotenv_folder" {
  bucket  = var.dotenv_bucket.id
  key     = "${var.module_name}/.env.${var.github_info.branch}"
  content = "# Sample file created by terraform"
}