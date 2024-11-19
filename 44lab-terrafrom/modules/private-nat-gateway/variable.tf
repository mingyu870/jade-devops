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
variable "vpc_id" {
  type        = string
  description = "vpc id"
}

variable "default_route_table_id" {
  type        = string
  description = "default route table id"
}

variable "public_subnet" {
  type = map(object({
    az_id = string
    az    = string
    id    = string
    arn   = string
  }))
  description = "public subnets"
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
