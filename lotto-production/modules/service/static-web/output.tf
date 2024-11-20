output "cf" {
  value = aws_cloudfront_distribution.cf_distribution
}

output "service_domain" {
  value = aws_route53_record.cf_route53_alias
}
