# route 53
resource "aws_route53_record" "cf_route53_alias" {
  zone_id = var.route53_domain_zone_id
  name    = var.sub_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cf_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cf_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
