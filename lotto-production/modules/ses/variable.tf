variable "project_name" {
  type        = string
  description = "project name for tagging"
}

variable "full_domain" {
  type    = string
  default = "full domain name"
}

variable "module_name" {
  type        = string
  description = "module name for naming"
}

variable "domain_zone_id" {
  type        = string
  description = "route 53 zone id. for verify domain"
}

variable "tester_email" {
  type    = set(string)
  default = ["jade@kpxdx.com"]
}
