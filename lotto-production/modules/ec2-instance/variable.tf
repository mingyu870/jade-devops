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

variable "instance_type" {
  type        = string
  description = "rds instance type"
}

variable "ami" {
  type        = string
  description = "ami for lunch instance"
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

variable "exclude_subnet_azs" {
  type        = set(string)
  description = "Sometimes some subnet does not support some instance type. This for Exclude not support azs. Az looks like 'apne2-az1'"
}

variable "vpc_id" {
  type        = string
  description = "vpc id"
}

# EC2-1 ingress rule
variable "ingress_rules" {
  type = map(object({
    description                  = string
    from_port                    = number
    to_port                      = number
    protocol                     = string
    cidr_ipv4                    = string
    cidr_ipv6                    = string
    referenced_security_group_id = string
  }))
  description = "Set of ingress rules for the security group"
}

variable "redis_security_group_id" {
  type        = string
  description = "Allow redis connect from ec2 bastion"
}

variable "redis_port" {
  type        = number
  description = "redis port for allow RDS connect from ec2 bastion"
}
