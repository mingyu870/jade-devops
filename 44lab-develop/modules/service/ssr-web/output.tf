output "ecr" {
  value = aws_ecr_repository.ssr_web
}

output "service_domain" {
  value = aws_route53_record.domain
}


