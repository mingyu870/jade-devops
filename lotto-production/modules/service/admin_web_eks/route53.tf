resource "aws_route53_record" "domain" {
  zone_id = var.route53_domain_zone_id
  name    = var.sub_domain
  type    = "A"
  alias {
    evaluate_target_health = true
    name                   = aws_lb.admin_web_eks.dns_name
    zone_id                = aws_lb.admin_web_eks.zone_id
  }
}
