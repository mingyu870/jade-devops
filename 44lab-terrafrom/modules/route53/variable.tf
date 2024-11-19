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

variable "origin_domain_name" {
  type        = string
  description = "origin domain name for NS register. read README.MD"
}

variable "subdomain_suffix" {
  type        = string
  description = "domain suffix. full domain is $${full_proj_name}-$${subdomain_suffix}-$${domain_name}"
  default     = ""
}

variable "subdomain" {
  type        = string
  description = "manually register subdomain name. if empty full domain will be $${full_proj_name}-$${subdomain_suffix}-$${domain_name}"
  default     = ""
}
