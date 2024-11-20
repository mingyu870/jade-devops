##############################
# route53
##############################
output "domain" {
  value = aws_route53_zone.domain
}

output "domain_name" {
  value = aws_route53_zone.domain.name
}

output "domain_zone_id" {
  value = aws_route53_zone.domain.zone_id
}

output "domain_name_servers" {
  value = aws_route53_zone.domain.name_servers
}
##############################
# acm(ssl)
##############################
output "valid_certificate" {
  value = aws_acm_certificate_validation.valid_acm
}

output "certificate" {
  value = aws_acm_certificate.cert
}

# global acm
output "global_valid_certificate" {
  value = aws_acm_certificate_validation.global_valid_acm
}

output "global_certificate" {
  value = aws_acm_certificate.global_cert
}
