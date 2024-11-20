# codebuild.tf
resource "aws_iam_role" "codebuild_role" {
  name               = "${var.full_proj_name}-codebuild-role-${var.module_name}"
  assume_role_policy = templatefile("${path.module}/iam/trust-policies/codebuild.tpl", { none = "none" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "attach_policy_to_role" {
  role = aws_iam_role.codebuild_role.name
  name = "codebuild_policy_${var.module_name}"
  policy = templatefile("${path.module}/iam/role-policies/iam-codebuild-role.tpl", {
    data_aws_region                 = var.aws_region
    data_aws_current_id             = data.aws_caller_identity.current.id
    data_s3_bucket_codepipeline_arn = var.codepipeline_artifact_bucket.arn
    data_s3_bucket_dotenv_arn       = var.dotenv_bucket.arn
    data_ecr_arn                    = aws_ecr_repository.ssr_web.arn
    data_codebuild_log_group_name   = local.codebuild_cloudwatch_log_group_name
    data_codebuild_name             = local.codebuild_project_name
  })

}

# codepipeline.tf
resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.full_proj_name}-codepipeline-role-${var.module_name}"
  assume_role_policy = templatefile("${path.module}/iam/trust-policies/codepipeline.tpl", { none = "none" })

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_iam_policy" "codepipeline_policy" {
  name   = "codepipeline_policy_${var.module_name}"
  policy = templatefile("${path.module}/iam/role-policies/iam-codepipeline-role.tpl", { none = "none" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy" {
  role       = aws_iam_role.codepipeline_role.id
  policy_arn = aws_iam_policy.codepipeline_policy.arn

  lifecycle {
    create_before_destroy = true
  }
}
