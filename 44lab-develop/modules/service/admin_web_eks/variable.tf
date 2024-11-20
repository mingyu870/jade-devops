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
  description = "EKS service port"
}

# eks.tf
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

variable "eks_options" {
  type = object({
    desired_size = number       # EKS 노드 그룹의 초기 노드 수
    min_size     = number       # EKS 노드 그룹의 최소 노드 수
    max_size     = number       # EKS 노드 그룹의 최대 노드 수
    instance_type = string      # EKS 노드의 인스턴스 유형 (예: "t3.medium")
    disk_size     = number      # EKS 노드의 디스크 크기 (GB 단위)
    service_port  = number      # 애플리케이션 서비스 포트
    healthCheck = optional(object({
      command  = list(string)   # 헬스체크 명령어
      interval = number         # 헬스체크 주기 (초)
      timeout  = number         # 헬스체크 타임아웃 (초)
      retries  = number         # 헬스체크 재시도 횟수
    }))
  })
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

variable "rds_security_group_id" {
  type        = string
  description = "Allow RDS connect from esc"
}

variable "rds_port" {
  type        = number
  description = "RDS port for allow RDS connect from ecs"
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

variable "app_name" {
  description = "app name"
  type        = string
  default     = "admin-web-app"
}

variable "namespace" {
  description = "namespace"
  type        = string
  default     = "admin-web-app"
}

variable "admin_web_eks_cluster" {
  description = "EKS cluster name and ID"
  type = object({
    name = string
    id   = string
  })
}

variable "eks_node_role_arn" {
  description = "ARN of the EKS node IAM role"
  type        = string
}

/* variable "rds_security_group_id" {
  type        = string
  description = "Allow RDS connect from esc"
}

variable "rds_port" {
  type        = number
  description = "RDS port for allow RDS connect from ecs"
} */