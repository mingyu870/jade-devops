terraform {
  required_version = ">= 1.8.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.47"
    }

    awscc = {
      source                = "hashicorp/awscc"
      version               = "~> 0.75.0"
      configuration_aliases = [awscc.cc]
    }
  }
}

##############################
# provider
##############################

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region

  default_tags {
    tags = local.provider.default_tags.tags
  }
  ignore_tags {
    keys = local.provider.ignore_tags.keys
  }
}

provider "aws" {
  alias   = "us-east-1"
  profile = var.aws_profile
  region  = "us-east-1"

  default_tags {
    tags = local.provider.default_tags.tags
  }
  ignore_tags {
    keys = local.provider.ignore_tags.keys
  }
}

provider "awscc" {
  alias   = "cc"
  profile = var.aws_profile
  region  = var.aws_region
}

##############################
# local value
##############################

locals {
  full_proj_name = "${var.project_name}-${var.environment}"

  provider = {
    default_tags = {
      tags = {
        "Environment"        = var.environment
        "Project"            = var.project_name
        "CreateBy"           = var.developer_name
        "CreatedDateTimeUtc" = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
        "CreatedDateTimeKst" = formatdate("YYYY-MM-DD hh:mm:ss+09:00", timeadd(timestamp(), "9h"))
      }
    }

    ignore_tags = {
      keys = [
        "Project",
        "Environment",
        "CreateBy",
        "CreatedDateTimeUtc",
        "CreatedDateTimeKst"
      ]
    }
  }

}

##############################
# network
##############################

module "network" {
  source         = "../../modules/network"
  vpc_cidr       = "10.0.0.0/16"
  project_name   = var.project_name
  env            = var.environment
  full_proj_name = local.full_proj_name
}

##############################
# private net-gateway
##############################

module "private_net_gateway" {
  source                 = "../../modules/private-nat-gateway"
  vpc_id                 = module.network.vpc.id
  default_route_table_id = module.network.vpc.default_route_table_id
  public_subnet          = module.network.public_subnet
  private_subnet         = module.network.private_subnet
  project_name           = var.project_name
  env                    = var.environment
  full_proj_name         = local.full_proj_name
}


##############################
# private_vpc_endpoint
##############################

module "private_vpc_endpoint" {
  source                     = "../../modules/private-vpc-endpoint"
  exclude_ecr_vpce_subnet_az = var.exclude_ecr_api_end_point_region_name
  # this is for test delete "sg-03e1a0cfa978db697" after ingress vpce sg ids
  vpc_id              = module.network.vpc.id
  private_route_table = module.private_net_gateway.private_route_table
  private_subnet      = module.network.private_subnet
  project_name        = var.project_name
  env                 = var.environment
  full_proj_name      = local.full_proj_name
  region              = var.aws_region
}

/* ##############################
# database
##############################

# pwd 모듈에서 비밀번호 생성후 값 아용하기.
module "pwd_gen" {
  source = "../../global/utils/random-pwdgen"
}

module "mysql" {
  source         = "../../modules/database"
  module_name    = "aurora-mysql"
  db_name        = replace("${local.full_proj_name}-db", "-", "_")
  rds_pwd        = module.pwd_gen.pwd
  instance_type  = local.mysql_spec.instance_type
  vpc_id         = module.network.vpc.id
  private_subnet = module.network.private_subnet
  project_name   = var.project_name
  env            = var.environment
  full_proj_name = local.full_proj_name
  force_destroy  = var.force_destroy
}

output "mysql" {
  value = {
    endpoint        = module.mysql.rds.endpoint
    read_endpoint   = module.mysql.rds.reader_endpoint
    username        = module.mysql.rds.master_username
    password        = "see output 'mysql_pwd'"
    db_name         = module.mysql.rds.database_name
    engine_version  = module.mysql.rds.engine_version
    instance_class  = module.mysql.rds.db_cluster_instance_class
    cluster_members = module.mysql.rds.cluster_members
  }
}

output "mysql_pwd" {
  value     = module.mysql.rds.master_password
  sensitive = true
} */

##############################
# redis
##############################

module "redis" {
  source         = "../../modules/redis"
  module_name    = "redis"
  redis          = local.redis_instance
  vpc_id         = module.network.vpc.id
  private_subnet = module.network.private_subnet
  project_name   = var.project_name
  env            = var.environment
  full_proj_name = local.full_proj_name
}

output "redis" {
  value = {
    endpoint = module.redis.redis_endpoint
    port     = module.redis.redis.port
  }
}

##############################
# ec2 instance
##############################
module "ec2_bastion" {
  source                  = "../../modules/ec2-instance"
  module_name             = "bastion"
  instance_type           = local.bastion_spec.instance_type
  ami                     = local.bastion_spec.ami
  ingress_rules           = local.bastion_spec.ingress_rules
  exclude_subnet_azs      = local.bastion_spec.exclude_subnet_azs
  vpc_id                  = module.network.vpc.id
  public_subnet           = module.network.public_subnet
  redis_security_group_id = module.redis.redis_sg.id
  redis_port              = module.redis.redis.port
  project_name            = var.project_name
  env                     = var.environment
  full_proj_name          = local.full_proj_name
}

output "ec2_bastion" {
  value = {
    public_ip     = module.ec2_bastion.ec2.public_ip
    public_dns    = module.ec2_bastion.ec2.public_dns
    pem_filepath  = module.ec2_bastion.key_pair_file_path.filename
    instance_type = module.ec2_bastion.ec2.instance_type
  }
}

##############################
# route53
##############################

module "route53" {
  source      = "../../modules/route53"
  module_name = "route53"

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }

  origin_domain_name = var.origin_domain_name
  subdomain          = var.environment
  subdomain_suffix   = ""
  project_name       = var.project_name
  env                = var.environment
  full_proj_name     = local.full_proj_name
}

output "domain_name" {
  value = module.route53.domain_name
}

##############################
# s3
##############################

module "s3" {
  source      = "../../modules/s3"
  module_name = "s3"

  force_destroy  = var.force_destroy
  project_name   = var.project_name
  env            = var.environment
  full_proj_name = local.full_proj_name
}

output "s3" {
  value = {
    dotenv = {
      bucket_name   = module.s3.dotenv_bucket.bucket
      bucket_domain = module.s3.dotenv_bucket.bucket_regional_domain_name
    }
    service_storage = {
      bucket_name   = module.s3.service_storage_bucket.bucket
      bucket_domain = module.s3.service_storage_bucket.bucket_regional_domain_name
    }
    terraform_backend = {
      bucket_name   = module.s3.terraform_backend_bucket.bucket
      bucket_domain = module.s3.terraform_backend_bucket.bucket_regional_domain_name
    }
  }
}

##############################
# terraform backend lock table
##############################

module "dynamodb" {
  source      = "../../modules/dynamodb"
  # DynamoDB 테이블 생성 시 필요한 변수나 인수를 여기에 추가

}

##############################
# CICD base
##############################

module "CICD" {
  source = "../../modules/cicd-base"

  providers = {
    awscc.cc = awscc.cc
  }
  project_name            = var.project_name
  env                     = var.environment
  full_proj_name          = local.full_proj_name
  force_destroy           = var.force_destroy
  s3_service_bucket_arn   = module.s3.service_storage_bucket.arn
  sns_topic_arn           = "arn:aws:sns:region:account-id:topic-name"
}

output "CICD_codestar_connection_status" {
  value = module.CICD.codestar.connection_status
}

##############################
# waf
##############################

module "waf" {
  source         = "../../modules/security/waf"
  module_name    = "waf"
  project_name   = var.project_name
  env            = var.environment
  full_proj_name = local.full_proj_name
}

##############################
# EBS snapshot 
##############################
module "ebs-backup" {
  source  = "../../modules/ebs-backup"
  tag_key  = "Name"
  tag_value = "mysql-vol"
}

output "backup_vault_arn" {
  value = module.ebs-backup.backup_vault_arn
}

output "backup_plan_id" {
  value = module.ebs-backup.backup_plan_id
}
