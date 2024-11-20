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

variable "slack" {
  type = object({
    workspace_id          = string
    notify_channel_id     = string
    notify_all_channel_id = string
  })
  description = "Slack notification information. More information read `How to get slack IDs` in README.md"
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

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic for RDS alarms"
  type        = string
}

variable "google_chat_hook_url" {
  type        = string
  description = "Google Chat webhook URL for Lambda notifications"
}

variable "google_chat_hook_url_2" {
  type        = string
  description = "Google Chat webhook URL for Lambda notifications"
}