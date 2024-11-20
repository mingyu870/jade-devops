# EKS 클러스터 생성
resource "aws_eks_cluster" "admin_web_eks_cluster" {
  name     = "${var.full_proj_name}-${var.full_proj_name}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn


  vpc_config {
    subnet_ids = values({ for k, v in var.private_subnet : k => v.id })
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy_attachment]
}

# EKS 워커 노드 그룹 생성
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.admin_web_eks_cluster.name
  node_group_name = "${var.full_proj_name}-${var.full_proj_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = values({ for k, v in var.private_subnet : k => v.id })
  scaling_config {
    desired_size = var.eks_options.desired_size
    max_size     = var.eks_options.max_size
    min_size     = var.eks_options.min_size
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy_attachment,
    aws_iam_role_policy_attachment.eks_cni_policy_attachment,
    aws_iam_role_policy_attachment.ec2_container_policy_attachment
  ]  
}

# 애플리케이션 디플로이먼트
resource "kubernetes_manifest" "app_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = var.app_name
      namespace = var.namespace
    }
    spec = {
      replicas = var.eks_options.replicas
      selector = {
        matchLabels = {
          app = var.app_name
        }
      }
      template = {
        metadata = {
          labels = {
            app = var.app_name
          }
        }
        spec = {
          containers = [{
            name  = var.app_name
            image = "${aws_ecr_repository.app.repository_url}:latest"
            ports = [{
              containerPort = var.service_port
            }]
            livenessProbe = {
              httpGet = {
                path = "/health"
                port = var.service_port
              }
              initialDelaySeconds = 30
              periodSeconds       = 10
            }
          }]
        }
      }
    }
  }
}

# 애플리케이션 서비스
resource "kubernetes_manifest" "app_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = var.app_name
      namespace = var.namespace
    }
    spec = {
      type = "LoadBalancer"
      ports = [{
        port       = var.service_port
        targetPort = var.service_port
      }]
      selector = {
        app = var.app_name
      }
    }
  }
}

