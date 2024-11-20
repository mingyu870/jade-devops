# ECS Cluster 분리 생성

resource "aws_ecs_cluster" "admin_api_ecs_cluster" {
  name = "${var.full_proj_name}-admin_api_ecs_cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name = "${var.full_proj_name}-admin_api_ecs_cluster"
  }
}

resource "aws_ecs_cluster" "member_api_ecs_cluster" {
  name = "${var.full_proj_name}-member_api_ecs_cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name = "${var.full_proj_name}-member_api_ecs_cluster"
  }
}

resource "aws_ecs_cluster" "admin_web_ecs_cluster" {
  name = "${var.full_proj_name}-admin_web_ecs_cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name = "${var.full_proj_name}-admin_web_ecs_cluster"
  }
}


# iam 생성
resource "aws_iam_role" "ecs_task_role" {
  name               = "ecsTaskRole"
  assume_role_policy = templatefile("${path.module}/iam/trust-policies/ecs_task.tpl", { none = "none" })

  tags = {
    Name = "${var.full_proj_name}-ecsTaskRole"
  }
}

resource "aws_iam_policy" "ecs_exec_docker" {
  name        = "ecsExecDokcer"
  description = "Ecs Exec docker"
  policy      = templatefile("${path.module}/iam/role-policies/ecs_docker.tpl", { none = "none" })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role__ecs_docker_attach" {
  policy_arn = aws_iam_policy.ecs_exec_docker.arn
  role       = aws_iam_role.ecs_task_role.name
}

resource "aws_iam_policy" "ecs_extra_task_policy" {
  policy = templatefile("${path.module}/iam/role-policies/ecs_extra_task.tpl", {
    data_s3_service_bucket_arn = var.s3_service_bucket_arn
  })
  description = "extra policy for ecs role"
  name        = "ecsExtraTaskPolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_role__ecs_extra_task_policy_attach" {
  policy_arn = aws_iam_policy.ecs_extra_task_policy.arn
  role       = aws_iam_role.ecs_task_role.name
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = templatefile("${path.module}/iam/trust-policies/ecs_task_execution.tpl", { none = "none" })

  tags = {
    Name = "${var.full_proj_name}-ecsTaskExecutionRole"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role__AmazonECSTaskExecutionRolePolicy" {
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
  role       = aws_iam_role.ecs_task_execution_role.name
}

resource "aws_iam_policy" "ecs_task_execution_role_extra" {
  name        = "ecsTaskExecutionRoleExtra"
  description = "Extra ecs task execution role."
  policy      = templatefile("${path.module}/iam/role-policies/ecs_task_execution_extra.tpl", { none = "none" })
}


resource "aws_iam_role_policy_attachment" "ecs_task_execution_role__ecs_task_execution_role_extra" {
  policy_arn = aws_iam_policy.ecs_task_execution_role_extra.arn
  role       = aws_iam_role.ecs_task_execution_role.name
}
