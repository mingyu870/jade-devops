##############################
# ec2
##############################
# RSA key of size 4096 bits
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  key_name   = "ec2-pmm.pem"
  public_key = tls_private_key.rsa.public_key_openssh
  tags = {
    Name = "ec2-${var.module_name}-key-pair-${var.full_proj_name}"
  }
}

resource "local_file" "ec2_pmm_key" {
  filename        = "ec2-${var.module_name}.pem"
  content         = tls_private_key.rsa.private_key_pem
  file_permission = 400
}

resource "random_shuffle" "public_subnet_id" {
  input = [
    for az_id, subnet in var.public_subnet : subnet.id
    if !contains(var.exclude_subnet_azs, az_id)

  ]

  result_count = 1
}

##############################
# EC2 Instances
##############################
resource "aws_instance" "ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ec2.key_name
  subnet_id              = random_shuffle.public_subnet_id.result[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "ec2-${var.module_name}-instance-${var.full_proj_name}-server"
  }
}

##############################
# Security Group
##############################
resource "aws_security_group" "ec2_sg" {
  name        = "${var.full_proj_name}-${var.module_name}-ec2-sg"
  description = "${var.full_proj_name}-${var.module_name}-ec2-sg"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.full_proj_name}-${var.module_name}-ec2-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = var.ingress_rules

  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  security_group_id = aws_security_group.ec2_sg.id
  description       = each.value.description
  tags = {
    Name = each.value.description
  }

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  referenced_security_group_id = each.value.referenced_security_group_id
}

##############################
# Application Load Balancer (ALB)
##############################
resource "aws_lb" "pmm_lb" {
  name               = "${var.full_proj_name}-${var.module_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2_sg.id]
  subnets            = values({ for k, v in var.public_subnet : k => v.id })

  enable_deletion_protection = false
  enable_http2              = true
  idle_timeout              = 60

  #enable_deletion_protection = !var.force_destroy

  tags = {
    Name = "${var.full_proj_name}-${var.module_name}-pmm-lb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.pmm_lb.arn
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

  tags = {
    Name = "${var.full_proj_name}-${var.module_name}-http-listener"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.pmm_lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:ap-southeast-1:961341522940:certificate/b750e1e5-ba7c-47fe-867a-f8ce09faec2b" # 인증서 ARN

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ec2_tg.arn
  }

  tags = {
    Name = "${var.full_proj_name}-${var.module_name}-https-listener"
  }
}

##############################
# Target Group
##############################
resource "aws_lb_target_group" "ec2_tg" {
  name     = "${var.full_proj_name}-${var.module_name}-tg"
  port     = 80
  protocol = "HTTP"
  deregistration_delay = 60
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    port                = 8123
  }

  tags = {
    Name = "${var.full_proj_name}-${var.module_name}-tg"
  }
}

##############################
# Target Group Attachment
##############################
resource "aws_lb_target_group_attachment" "ec2_attachment" {
  target_group_arn = aws_lb_target_group.ec2_tg.arn
  target_id        = aws_instance.ec2.id
  port             = 80
}


##############################
# Route53 Recode set
##############################

resource "aws_route53_record" "domain" {
  zone_id = var.route53_domain_zone_id
  name    = var.sub_domain
  type    = "A"
  alias {
    evaluate_target_health = false
    name                   = aws_lb.pmm_lb.dns_name
    zone_id                = aws_lb.pmm_lb.zone_id
  }
}


##########################
# EC2 - Healthcheck - fail
##########################
resource "aws_cloudwatch_metric_alarm" "ec2_health_alarm" {
  alarm_name                = "${var.full_proj_name}-ec2-health-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "UnHealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "1"  # Trigger the alarm if the status check fails
  datapoints_to_alarm       = "1"

  alarm_description         = "Trigger alarm when the EC2 instance has failed its status checks."

  dimensions = {
    TargetGroup  = "targetgroup/llg-production-pmm-tg/453ddb485ffe34bd"
    LoadBalancer = "app/llg-production-pmm-alb/8eb4d0ae256de42f"
    AvailabilityZone = "ap-southeast-1b"
  }

  alarm_actions = ["arn:aws:sns:ap-southeast-1:961341522940:llg-production-resource-alarm-topic"]
}