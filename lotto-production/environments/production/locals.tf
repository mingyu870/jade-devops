
locals {
/* ##############################
# RDS local set
##############################
  mysql_spec = {
    instance_type    = "db.t3.medium"
  } */

# EC2-1 spec setup
  bastion_spec = {
    instance_type      = "t2.micro"
    ami                = "ami-0c5303379cc3cc927" # Amazon Linux 2023 AMI seoul region
    exclude_subnet_azs = []
    ingress_rules = {
      office_wifi_http = {
        description = "Dosan-daero 5f GPEX wifi 5g"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_ipv4   = "61.78.96.20/32"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
      office_wifi_ssh = {
        description = "Dosan-daero 5f GPEX wifi 5g"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_ipv4   = "61.78.96.20/32"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
    }
  }

# EC2-2 spec setup
  pmm_spec = {
    instance_type      = "m5.large"
    ami                = "ami-0b56e8c4b84e2223a" # Amazon Linux 2023 AMI seoul region
    exclude_subnet_azs = []
    ingress_rules = {
      office_wifi_http = {
        description = "Dosan-daero 5f GPEX wifi 5g"
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_ipv4   = "61.78.96.20/32"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
        office_wifi_https = {
        description = "Dosan-daero 5f GPEX wifi 5g"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_ipv4   = "61.78.96.20/32"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
      office_wifi_ssh = {
        description = "Dosan-daero 5f GPEX wifi 5g"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_ipv4   = "61.78.96.20/32"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
      pmm_service1 = {
        description = "ppm-mysql-port-4433"
        from_port   = 4433
        to_port     = 4433
        protocol    = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
      pmm_service2 = {
        description = "ppm-mysql-port-443"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
      pmm_service4 = {
        description = "ppm-mysql-port-80"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
      pmm_service5 = {
        description = "ppm-port-8123"
        from_port   = 8123
        to_port     = 8123
        protocol    = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
      pmm_service6 = {
        description = "ppm-port-9000"
        from_port   = 9000
        to_port     = 9000
        protocol    = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
      pmm_service7 = {
        description = "loki-port-9096"
        from_port   = 9096
        to_port     = 9096
        protocol    = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
      pmm_service8 = {
        description = "loki-port-3100"
        from_port   = 3100
        to_port     = 3100
        protocol    = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
      pmm_service9 = {
        description = "clickhouse-port-9440"
        from_port   = 9440
        to_port     = 9440
        protocol    = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
      pmm_service10 = {
        description = "promtail-port-9098"
        from_port   = 9098
        to_port     = 9098
        protocol    = "tcp"
        cidr_ipv4   = "0.0.0.0/0"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
      pmm_service11 = {
        description = "mysql-port-3306"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_ipv4   = null
        # if you need
        referenced_security_group_id = "sg-0e4b6418fc7bbe369"
        cidr_ipv6                    = null
      }         
    }
  }

  # EC2-3 spec setup
  db_mysql_spec = {
    instance_type      = "c7g.2xlarge"
    ami                = "ami-06b21378510313f12" # AMI -ARM64
  
    exclude_subnet_azs = []
    ingress_rules = {
      office_wifi_http = {
        description = "Dosan-daero 5f GPEX wifi 5g"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_ipv4   = "61.78.96.20/32"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
      office_private_ssh = {
        description = "private ssh"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_ipv4   = "10.0.15.139/32"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
        office_private_sql = {
        description = "private sql"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_ipv4   = "10.0.0.0/8"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
        office_private_redis = {
        description = "allow redis"
        from_port   = 6379
        to_port     = 6379
        protocol    = "tcp"
        cidr_ipv4   = "10.0.0.0/8"
        # if you need
        referenced_security_group_id = null
        cidr_ipv6                    = null
      }
        admin_api_service = {
        description = "llg-admin-api-service-sg"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_ipv4   = null
        referenced_security_group_id = "sg-0af4886e2c80b7261"
        cidr_ipv6                    = null
      }
        ssr_web_service = {
        description = "llg-ssr-web-service-sg"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_ipv4   = null
        referenced_security_group_id = "sg-09fbc688fdf4aa769"
        cidr_ipv6                    = null
      } 
        bastion_ec2 = {
        description = "llg-bastion-ec2-sg"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_ipv4   = null
        referenced_security_group_id = "sg-0cb609ed6ef65c3a2"
        cidr_ipv6                    = null
      } 
        member_api_service = {
        description = "llg-member-api-service-sg"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_ipv4   = null
        referenced_security_group_id = "sg-0efef2ccb563cc3b1"
        cidr_ipv6                    = null
      }
    }
  }


  redis_instance = {
    #     node_type = "cache.m6g.large"
    node_type               = "cache.r7g.large"
    engine_version          = "7.1.0"
    port                    = 6379
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