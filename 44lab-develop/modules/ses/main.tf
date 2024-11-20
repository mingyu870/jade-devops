# SES Email Identity 설정
resource "aws_sesv2_email_identity" "domain" {
  email_identity = var.full_domain
}

resource "aws_sesv2_email_identity" "tester_email" {
  for_each       = var.tester_email
  email_identity = each.value
}

# It can be manually verify, If you can't control route53 using terraform
resource "aws_route53_record" "verify_dkim" {
  for_each = toset(aws_sesv2_email_identity.domain.dkim_signing_attributes[0].tokens)

  zone_id = var.domain_zone_id # Route 53 Hosted Zone ID
  name    = "${each.value}._domainkey.${var.full_domain}"
  type    = "CNAME"
  ttl     = 300
  records = ["${each.value}.dkim.amazonses.com"]
}
