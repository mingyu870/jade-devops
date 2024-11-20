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

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "module_name" {
  type        = string
  description = "module name for naming"
}

variable "sub_domain" {
  type        = string
  description = "sub domain"
}

variable "force_destroy" {
  type        = bool
  description = "Force destroy S3, ECR and etc..."
  default     = false
}

variable "dotenv_bucket" {
  type = object({
    arn    = string
    bucket = string
    id     = string
  })
  description = "Load for dotenv files"
}

variable "github_info" {
  type = object({
    repo_name = string
    branch    = string
  })
}

variable "codestar_connection_arn" {
  type        = string
  description = "Code star connection arn"
}

# chatbot.tf
variable "chatbot_slack_notify_config_arn" {
  type        = string
  description = "awscc_chatbot_slack_channel_configuration slack-notify arn"
}

variable "chatbot_slack_all_notify_config_arn" {
  type        = string
  description = "awscc_chatbot_slack_channel_configuration slack-all-notify arn"
}

## cicd-base/chatbot.tf aws_sns_topic sns-topic.arn
variable "sns_topic_notify_arn" {
  type        = string
  description = "aws_sns_topic slack notify arn"
}

variable "sns_topic_all_notify_arn" {
  type        = string
  description = "aws_sns_topic slack all notify arn"
}

# cloudfront tls
variable "global_acm_cer_arn" {
  type        = string
  description = "aws acm certificate arn"
}

variable "waf_arn" {
  type        = string
  description = "Waf acl arn for load balancer"
}

# route53
variable "route53_domain_zone_id" {
  type        = string
  description = "route53 domain zone id"
}

variable "full_domain" {
  type        = string
  description = "full domain. `env.doamin`"
}

# codebuild
variable "environment_variables" {
  type = map(object({
    name  = string
    value = string
    type  = string
  }))
  default = {}
}

# codepipeline
variable "codepipeline_artifact_bucket" {
  type = object({
    arn    = string
    bucket = string
    id     = string
  })
  description = "Codepipeline bucket. For artifact"
}

variable "codepipeline_trigger_file_paths" {
  type        = set(string)
  description = "codebuild trigger file paths "
  default     = []
}

variable "codepipeline_trigger_branches" {
  type        = set(string)
  description = "codebuild trigger git branches "
  default     = []
}
