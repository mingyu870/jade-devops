
locals {
##############################
# RDS local set
##############################
  mysql_spec = {
    instance_type    = "db.t3.medium"
  }

# EC2-1 spec setup
  bastion_spec = {
    instance_type      = "t2.micro"
    ami                = "ami-0c5303379cc3cc927" # Amazon Linux 2023 AMI seoul region
    exclude_subnet_azs = []
    ingress_rules = {
      office_wifi_http = {
        description    = "office wifi web"
        from_port      = 80
        to_port        = 80
        protocol       = "tcp"
        cidr_ipv4      = "0.0.0.0/32"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
      office_wifi_ssh = {
        description = "office wifi ssh"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_ipv4   = "0.0.0.0/32"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
    }
  }

  redis_instance = {
    #     node_type = "cache.m6g.large"
    node_type                  = "cache.t4g.micro"
    engine_version             = "7.1.0"
    port                       = 6379
    num_node_groups            = 1 
    replicas_per_node_group    = 0 
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