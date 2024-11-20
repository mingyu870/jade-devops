locals {
  lb_tg_health_check_options_default = {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/api/health"
    port                = "traffic-port"
    protocol            = "HTTP"
  }
  lb_name_trimmed = substr("${var.full_proj_name}-${var.module_name}-ssr-alb", 0, 32)
  lb_name         = replace(local.lb_name_trimmed, "/-$/", "")
}

resource "aws_lb" "ssr_web" {
  name               = local.lb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = values({ for k, v in var.public_subnet : k => v.id })
  security_groups    = [aws_security_group.ssr_web_services_alb.id]

  enable_deletion_protection = !var.force_destroy
}

resource "aws_lb_target_group" "ssr_web" {
  name        = "${var.full_proj_name}-${var.module_name}-tg"
  port        = var.service_port
  protocol    = "HTTP"
  deregistration_delay = 60
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = lookup(var.lb_tg_health_check_options, "healthy_threshold", local.lb_tg_health_check_options_default.healthy_threshold)
    unhealthy_threshold = lookup(var.lb_tg_health_check_options, "unhealthy_threshold", local.lb_tg_health_check_options_default.unhealthy_threshold)
    timeout             = lookup(var.lb_tg_health_check_options, "timeout", local.lb_tg_health_check_options_default.timeout)
    interval            = lookup(var.lb_tg_health_check_options, "interval", local.lb_tg_health_check_options_default.interval)
    path                = lookup(var.lb_tg_health_check_options, "path", local.lb_tg_health_check_options_default.path)
    port                = lookup(var.lb_tg_health_check_options, "port", local.lb_tg_health_check_options_default.port)
    protocol            = lookup(var.lb_tg_health_check_options, "protocol", local.lb_tg_health_check_options_default.protocol)
  }
}

resource "aws_lb_listener" "ssr_web_http" {
  load_balancer_arn = aws_lb.ssr_web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "ssr_web_https" {
  load_balancer_arn = aws_lb.ssr_web.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.acm_cer_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ssr_web.arn
  }
}


