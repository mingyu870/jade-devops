##############################
# llg member web frontend
##############################

module "llg-member-web-frontend" {
  source      = "../../modules/service/static-web"
  module_name = local.llg-member-web.module-name

  depends_on = [
    module.route53,
    module.private_vpc_endpoint
  ]

  # default variable
  project_name   = var.project_name
  env            = var.environment
  full_proj_name = local.full_proj_name

  force_destroy                       = var.force_destroy
  aws_region                          = var.aws_region
  global_acm_cer_arn                  = module.route53.global_certificate.arn
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
  github_info            = local.llg-member-web.github_info
  route53_domain_zone_id = module.route53.domain.zone_id
  sub_domain             = "member"
  full_domain            = "${var.environment}.${var.origin_domain_name}"
  waf_arn                = module.waf.waf_acl.arn

  # codebuild
  environment_variables = {
    s3_project_folder = {
      name  = "S3_PROJECT_FOLDER"
      value = local.llg-member-web.module-name
      type  = "PLAINTEXT"
    }
  }

  codepipeline_trigger_branches = [
    "${local.llg-member-web.github_info.branch}"
  ]
  #   codepipeline_trigger_file_paths = [
  #     "src/main*.ts",
  #     "src/member/**/*",
  #     "src/common/**/*",
  #     "src/_entities/**/*",
  #     "cicd/**/*",
  #   ]
}

locals {
  llg-member-web = {
    module-name = "member-web"
    github_info = {
      repo_name = "kpxinc/lotto_laos_web" #pipeline 동작을 멈추기 위해서 web -> webss  로 변경 
      branch    = "production"
    }
  }
}

output "service_llg-member-web-frontend" {
  value = module.llg-member-web-frontend.service_domain.fqdn
}