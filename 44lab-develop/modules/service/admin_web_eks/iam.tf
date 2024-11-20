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
    data_ecr_arn                    = aws_ecr_repository.admin_web_eks.arn
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

# EKS 클러스터용 IAM 역할
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.full_proj_name}-${var.full_proj_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# EKS 클러스터 역할에 대한 정책 첨부
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS 노드 그룹용 IAM 역할
resource "aws_iam_role" "eks_node_role" {
  name = "${var.full_proj_name}-${var.full_proj_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# EKS 노드 역할에 정책 첨부 (EC2 및 EKS 권한)
resource "aws_iam_role_policy_attachment" "eks_node_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
