variable "project_name" {
  type        = string
  description = "project name for tagging"
}

variable "env" {
  type        = string
  description = "environment for tagging"
}

variable "full_proj_name" {
  type        = string
  description = "project_name + env"
}

variable "force_destroy" {
  type        = bool
  description = "Force destroy S3, ECR and etc..."
  default     = false
}

variable "s3_service_bucket_arn" {
  type        = string
  description = "s3 service bucket arn for file up download on ecs services"
}
