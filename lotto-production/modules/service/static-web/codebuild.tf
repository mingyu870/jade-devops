resource "aws_codebuild_project" "frontend" {
  name          = local.codebuild_project_name
  description   = "${var.full_proj_name} ${var.module_name} codebuild project"
  build_timeout = 30
  service_role  = aws_iam_role.codebuild_role.arn

  source {
    type = "CODEPIPELINE"
    # path in project source code
    buildspec = "cicd/codebuild/${var.github_info.branch}/buildspec.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
    name = "${var.full_proj_name}-${var.module_name}-codebuild-artifact"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "DEPLOY_ENV"
      value = var.github_info.branch
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "S3_DOTENV_BUCKET_NAME"
      value = var.dotenv_bucket.bucket
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "S3_DEPLOY_BUCKET_NAME"
      value = aws_s3_bucket.distribution.bucket
      type  = "PLAINTEXT"
    }

    environment_variable {
      name  = "DISTRIBUTION_ID"
      value = aws_cloudfront_distribution.cf_distribution.id
      type  = "PLAINTEXT"
    }

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = environment_variable.value.type
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = local.codebuild_cloudwatch_log_group_name
    }
  }
}
