# How to add module to waf
Connecting modules to the WAF is done by passing the `waf arn` to the modules and then opening them to each module. See below

```hcl
module "another_module" {
  ## ...another information
  waf_arn                     = module.waf.waf_acl.arn
}

resource "aws_wafv2_web_acl_association" "connect_waf_lb" {
  resource_arn = aws_lb.another_module.arn
  web_acl_arn  = var.waf_arn
}

```
