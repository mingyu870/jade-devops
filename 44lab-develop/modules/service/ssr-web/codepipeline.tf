resource "aws_codepipeline" "ssr_web" {
  name           = "${var.full_proj_name}-${var.module_name}-pipeline"
  role_arn       = aws_iam_role.codepipeline_role.arn
  pipeline_type  = "V2"
  execution_mode = "QUEUED"

  artifact_store {
    location = var.codepipeline_artifact_bucket.bucket
    type     = "S3"
  }

  dynamic "trigger" {
    for_each = length(var.codepipeline_trigger_file_paths) > 0 || length(var.codepipeline_trigger_branches) > 0 ? [1] : []
    content {
      provider_type = "CodeStarSourceConnection"
      git_configuration {
        source_action_name = "Source"
        push {
          branches {
            includes = length(var.codepipeline_trigger_branches) > 0 ? var.codepipeline_trigger_branches : [var.github_info.branch]
          }
          dynamic "file_paths" {
            for_each = length(var.codepipeline_trigger_file_paths) > 0 ? [1] : []
            content {
              includes = var.codepipeline_trigger_file_paths
            }
          }
        }
      }
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = var.github_info.repo_name
        BranchName       = var.github_info.branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.ssr_web.name

      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName = var.admin_web_ecs_cluster.name
        ServiceName = aws_ecs_service.ssr_web.name
      }
    }
  }
}

