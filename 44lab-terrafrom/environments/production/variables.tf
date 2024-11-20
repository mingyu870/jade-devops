# project setting
variable "project_name" {
  type        = string
  description = "It will be name of aws resources. "
}

variable "environment" {
  type        = string
  description = "development environment"
}

variable "developer_name" {
  type        = string
  description = "developer name for run terraform"
}

# aws config
variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_profile" {
  type        = string
  description = "for running terraform aws profile"
}

# route53
variable "origin_domain_name" {
  type        = string
  description = "origin domain name"
}


# for test
variable "force_destroy" {
  type        = bool
  description = "force destroy s3 and ecr for testing. When product deployment, This should be false"
}

# exceptions
variable "exclude_ecr_api_end_point_region_name" {
  #  region name like 'apne2-az4'
  type        = set(string)
  description = "some region does not support. seoul region does not support ecr api end point on az-d."
  default     = []
}