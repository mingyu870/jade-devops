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

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR for vpc. 16-bit range(e.g. 10.0.0.0/16)"

  validation {
    condition     = contains(split("/", var.vpc_cidr), "16")
    error_message = "CIDR is must be 16-bit (e.g. 10.0.0.0/16)"
  }
}
