locals {
  # codebuild
  codebuild_project_name              = "${var.full_proj_name}-${var.module_name}-codebuild"
  codebuild_cloudwatch_log_group_name = "/aws/codebuild/${var.full_proj_name}/${var.module_name}"

  # ecs
  eks_service_name = "${var.full_proj_name}-${var.module_name}-eks-service"
}
