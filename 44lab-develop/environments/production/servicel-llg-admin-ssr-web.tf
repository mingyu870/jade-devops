##############################
# llg admin ssr web
##############################

module "llg-admin-ssr-web" {
  source      = "../../modules/service/ssr-web"
  module_name = local.llg-admin-ssr-web.module-name

  depends_on = [
    module.route53,
    module.private_vpc_endpoint
  ]

  # default variable
  project_name   = var.project_name
  env            = var.environment
  full_proj_name = local.full_proj_name
  service_port   = local.llg-admin-ssr-web_service_port

  force_destroy                       = var.force_destroy
  aws_region                          = var.aws_region
  acm_cer_arn                         = module.route53.certificate.arn
  chatbot_slack_all_notify_config_arn = module.CICD.chatbot_slack_all_notify.arn
  chatbot_slack_notify_config_arn     = module.CICD.chatbot_slack_notify.arn
  sns_topic_notify_arn                = module.CICD.sns_topic_slack_notify.arn
  sns_topic_all_notify_arn            = module.CICD.sns_topic_slack_all_notify.arn
  codepipeline_artifact_bucket = {
    arn    = module.CICD.codepipeline_artifact_bucket.arn
    bucket = module.CICD.codepipeline_artifact_bucket.bucket
    id     = module.CICD.codepipeline_artifact_bucket.id
  }
  codestar_connection_arn = module.CICD.codestar.arn
  dotenv_bucket = {
    arn    = module.s3.dotenv_bucket.arn
    bucket = module.s3.dotenv_bucket.bucket
    id     = module.s3.dotenv_bucket.id
  }
  admin_web_ecs_cluster = {
    name = module.CICD.admin_web_ecs_cluster.name
    id   = module.CICD.admin_web_ecs_cluster.id
  }
  ecs_task_execution_role_arn = module.CICD.ecs_task_execution_role.arn
  ecs_task_role_arn           = module.CICD.ecs_task_role.arn
  ecs_options                 = local.llg-admin-ssr-web.ecs_options
  github_info                 = local.llg-admin-ssr-web.github_info
  lb_tg_health_check_options  = local.llg-admin-ssr-web.lb_tg_health_check_options
#  rds_security_group_id       = module.mysql.rds_sg.id
#  rds_port                    = module.mysql.rds.port
  redis_security_group_id     = module.redis.redis_sg.id
  redis_port                  = module.redis.redis.port
  route53_domain_zone_id      = module.route53.domain.zone_id
  sub_domain                  = "admin"
  private_subnet              = module.network.private_subnet
  public_subnet               = module.network.public_subnet
  vpc_id                      = module.network.vpc.id
  vpc_endpoint_sg_id          = module.private_vpc_endpoint.vpc_endpoint_security_group.id
  waf_arn                     = module.waf.waf_acl.arn

  # codebuild
  environment_variables = {
    s3_project_folder = {
      name  = "S3_PROJECT_FOLDER"
      value = local.llg-admin-ssr-web.module-name
      type  = "PLAINTEXT"
    }
  }

  codepipeline_trigger_branches = [
    "${local.llg-admin-ssr-web.github_info.branch}"
  ]
}

locals {
  llg-admin-ssr-web_service_port      = 3000
  llg-admin-ssr-web_health_check_path = "/api/health"
  llg-admin-ssr-web = {
    module-name = "admin-ssr-web"
    ecs_options = {
      desired_count = 2
      cpu           = 1024
      memory        = 2048
      service_port  = local.llg-admin-ssr-web_service_port
      healthCheck = {
        command = [
          "CMD-SHELL",
          "node healthCheck.js ${local.llg-admin-ssr-web_service_port} ${local.llg-admin-ssr-web_health_check_path} || exit 1"
        ],
        "interval" = 30
        "timeout"  = 5
        "retries"  = 3
      }
    }
    github_info = {
      repo_name = "kpxinc/lotto_laos_admin"  # pipeline 동작을 멈추기 위해서 admin -> adminss 로 변경
      branch    = "production"
    }
    lb_tg_health_check_options = {
      healthy_threshold   = 5
      unhealthy_threshold = 2
      timeout             = 5
      interval            = 30
      path                = local.llg-admin-ssr-web_health_check_path
      port                = "traffic-port"
      protocol            = "HTTP"
    }
  }
}

output "service_url_llg-admin-ssr-web" {
  value = module.llg-admin-ssr-web.service_domain.fqdn
}
