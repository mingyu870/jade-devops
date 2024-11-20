output "ecr" {
  value = aws_ecr_repository.admin_web_eks
}

output "service_domain" {
  value = aws_route53_record.domain
}

output "admin_web_eks_cluster_name" {
  value = aws_eks_cluster.admin_web_eks_cluster.name
}

output "admin_web_eks_cluster_id" {
  value = aws_eks_cluster.admin_web_eks_cluster.id
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

output "admin_web_eks_cluster" {
  value = aws_eks_cluster.admin_web_eks_cluster
}