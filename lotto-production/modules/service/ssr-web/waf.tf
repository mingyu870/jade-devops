resource "aws_wafv2_web_acl_association" "connect_waf_lb" {
  resource_arn = aws_lb.ssr_web.arn
  web_acl_arn  = var.waf_arn
}
