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

variable "service_port" {
  type        = number
  description = "ECS service port"
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

# ecs.tf
variable "vpc_id" {
  type = string
}

variable "vpc_endpoint_sg_id" {
  type        = string
  description = "Vpc endpoint security group id. This is for allow ecs to vpc endpoints"
}

variable "public_subnet" {
  type = map(object({
    az_id = string
    az    = string
    id    = string
    arn   = string
  }))
  description = "private subnets"
}

variable "private_subnet" {
  type = map(object({
    az_id = string
    az    = string
    id    = string
    arn   = string
  }))
  description = "private subnets"
}

variable "ecs_cluster" {
  type = object({
    name = string
    id   = string
  })
  description = "ECS cluster information"
}

variable "ecs_options" {
  type = object({
    desired_count = number
    cpu           = number
    memory        = number
    service_port  = number
    healthCheck = optional(object({
      command  = list(string)
      interval = number
      timeout  = number
      retries  = number
    }))
  })
}

variable "ecs_task_role_arn" {
  type        = string
  description = "IAM role for ecs task role"
}

variable "ecs_task_execution_role_arn" {
  type        = string
  description = "IAM role for ecs task execution role"
}

# lb.tf
variable "lb_tg_health_check_options" {
  type = object({
    healthy_threshold   = optional(number)
    unhealthy_threshold = optional(number)
    timeout             = optional(number)
    interval            = optional(number)
    path                = optional(string)
    port                = optional(string)
    protocol            = optional(string)
  })
}

variable "acm_cer_arn" {
  type        = string
  description = "aws acm certificate arn"
}

# security-group.tf
variable "add_rds_ingress_rules_ids" {
  type = map(object({
    description       = optional(string)
    security_group_id = string
    from_port         = optional(number)
    to_port           = optional(number)
    ip_protocol       = optional(string)
  }))
  default     = {}
  description = "Allow back-end services to RDS. Input RDS information"
}

variable "redis_security_group_id" {
  type        = string
  description = "Allow redis connect from ecs"
}

variable "redis_port" {
  type        = number
  description = "Redis port for allow redis connect from ecs"
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
