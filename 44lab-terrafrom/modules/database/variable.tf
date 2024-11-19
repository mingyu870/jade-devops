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

variable "module_name" {
  type        = string
  description = "module name for naming"
}

variable "db_name" {
  type        = string
  description = "db name"
}

variable "rds_pwd" {
  type        = string
  description = "rds root password"
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

variable "instance_type" {
  type        = string
  description = "rds instance type"
}

variable "force_destroy" {
  type        = bool
  description = "Force destroy"
}

variable "vpc_id" {
  type        = string
  description = "vpc id"
}