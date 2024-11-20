output "dotenv_bucket" {
  value = aws_s3_bucket.dotenv
}

output "service_storage_bucket" {
  value = aws_s3_bucket.service_storage
}

output "terraform_backend_bucket" {
  value = aws_s3_bucket.terraform_backend
}
