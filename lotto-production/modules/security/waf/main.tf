locals {
  role = {
    commonRule         = "AWSManagedRulesCommonRuleSet",
    knownBadInputsRule = "AWSManagedRulesKnownBadInputsRuleSet",
    SQLiRule           = "AWSManagedRulesSQLiRuleSet",
    linuxRule          = "AWSManagedRulesLinuxRuleSet"
  }
}

resource "aws_wafv2_web_acl" "waf" {
  name        = "${var.full_proj_name}-waf"
  description = "all the rules for ${var.full_proj_name} services"
  scope       = "REGIONAL"

  tags = {
    Name = "${var.full_proj_name}-waf"
  }

  token_domains = []

  default_action {
    allow {}
  }

  rule {
    name     = local.role.commonRule
    priority = 0

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = local.role.commonRule
        vendor_name = "AWS"
      }
    }

    visibility_config {
      metric_name                = local.role.commonRule
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = local.role.knownBadInputsRule
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = local.role.knownBadInputsRule
        vendor_name = "AWS"
      }
    }

    visibility_config {
      metric_name                = local.role.knownBadInputsRule
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = local.role.SQLiRule
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = local.role.SQLiRule
        vendor_name = "AWS"
      }
    }

    visibility_config {
      metric_name                = local.role.SQLiRule
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = local.role.linuxRule
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = local.role.linuxRule
        vendor_name = "AWS"
      }
    }

    visibility_config {
      metric_name                = local.role.linuxRule
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    metric_name                = "${var.full_proj_name}-metric"
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
  }
}

resource "aws_cloudwatch_log_group" "waf_logs_group" {
  # name must start with "aws-waf-logs-"
  # see more information https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration#log_destination_configs
  name = "aws-waf-logs-${var.full_proj_name}-log-group"
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs_group.arn]
  resource_arn            = aws_wafv2_web_acl.waf.arn
}
