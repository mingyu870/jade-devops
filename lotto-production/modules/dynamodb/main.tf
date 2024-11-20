
# DynamoDB 테이블 생성 (옵션)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  hash_key     = "LockID"
  read_capacity = 2
  write_capacity = 2
  billing_mode = "PROVISIONED"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    "Name" = "DynamoDB Terraform State Lock Table"
  }
  lifecycle {
    prevent_destroy = true   # Delete = false 
  }
}
