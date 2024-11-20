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

variable "redis" {
  type = object({
    node_type                = string
    engine_version           = string
    port                     = number
    num_node_groups          = number
    replicas_per_node_group  = number
    snapshot_retention_limit = number
    snapshot_window          = string
    multi_az_enabled         = bool
    parameter_group = object({
      family = string
    })
  })
  description = "redis variables"
  default = {
    #     node_type = "cache.m6g.large"
    node_type               = "cache.t4g.micro"
    engine_version          = "7.1.0"
    port                    = 6379
    num_node_groups         = 1
    replicas_per_node_group = 0
    # snapshot_retention_limit and snapshot_window have bug, if not working using cli
    # cli
    # aws elasticache modify-replication-group
    # --replication-group-id replication_group_id
    # --snapshot-retention-limit 7
    # --snapshot-window 06:00-07:00
    # see also https://github.com/hashicorp/terraform-provider-aws/issues/6412
    snapshot_retention_limit = 7
    snapshot_window          = "01:30-02:30"
    multi_az_enabled         = true
    parameter_group = {
      family = "redis7"
    }
  }
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

variable "vpc_id" {
  type        = string
  description = "vpc id"
}
