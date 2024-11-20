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

variable "region" {
  type        = string
  description = "region"
}

variable "private_route_table" {
  type = map(object({
    az_id = string
    id    = string
  }))
  description = "private route tables"
}

variable "vpc_id" {
  type        = string
  description = "vpc id"
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

variable "exclude_ecr_vpce_subnet_az" {
  type        = set(string)
  description = "some region does not support that ecr api and ecr drk. Input the az name like [apne2-az2]."
}
