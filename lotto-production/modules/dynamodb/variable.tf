# 필요한 변수 정의
variable "name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "terraform_locks"
}
