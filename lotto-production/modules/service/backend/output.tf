output "ecr" {
  value = aws_ecr_repository.backend
}

output "service_domain" {
  value = aws_route53_record.domain
}
