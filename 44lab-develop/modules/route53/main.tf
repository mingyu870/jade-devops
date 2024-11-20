##############################
# locals
##############################
locals {
  checked-domain-suffix = var.subdomain_suffix == "" ? "" : "-${var.subdomain_suffix}"
  subdomain             = var.subdomain == "" ? var.full_proj_name : var.subdomain
  full-domain-name      = "${local.subdomain}${local.checked-domain-suffix}.${var.origin_domain_name}"
}

##############################
# route53
##############################
resource "aws_route53_zone" "domain" {
  name = local.full-domain-name
}


##############################
# acm(ssl)
##############################
resource "aws_acm_certificate" "cert" {
  domain_name       = "*.${local.full-domain-name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.domain.zone_id
}

resource "aws_acm_certificate_validation" "valid_acm" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

# global acm
resource "aws_acm_certificate" "global_cert" {
  provider          = aws.us-east-1
  domain_name       = "*.${local.full-domain-name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "global_acm_validation" {
  provider = aws.us-east-1
  for_each = {
    for dvo in aws_acm_certificate.global_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.domain.zone_id
}

resource "aws_acm_certificate_validation" "global_valid_acm" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.global_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.global_acm_validation : record.fqdn]
}
