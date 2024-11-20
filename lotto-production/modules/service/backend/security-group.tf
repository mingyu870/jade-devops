# rds
# fixme maybe it is not need
resource "aws_vpc_security_group_ingress_rule" "rds_ingress_rule_ref_sg" {
  for_each          = var.add_rds_ingress_rules_ids
  security_group_id = each.value.security_group_id

  description                  = "allow-${var.module_name}-${each.value.description}"
  from_port                    = lookup(each.value, "from_port", 3360)
  to_port                      = lookup(each.value, "to_port", 3360)
  ip_protocol                  = each.value.ip_protocol == "" ? "tcp" : each.value.ip_protocol
  referenced_security_group_id = "it will be instance's or esc's security group id"
}

# ecs
resource "aws_security_group" "ecs_backend_services" {
  name        = "${var.full_proj_name}-${var.module_name}-service-sg"
  description = "${var.full_proj_name}-${var.module_name}-service-sg"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow service port from alb"
    from_port       = var.service_port
    to_port         = var.service_port
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_services_alb.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.full_proj_name}-${var.module_name}-service-sg"
  }
}

# alb
resource "aws_security_group" "backend_services_alb" {
  name        = "${var.full_proj_name}-${var.module_name}-alb-sg"
  description = "${var.full_proj_name}-${var.module_name}-alb-sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.full_proj_name}-${var.module_name}-alb-sg"
  }
}

locals {
  sg_ingress_rule_description = "allow from ${var.full_proj_name} ${var.module_name} ecs"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = var.vpc_endpoint_sg_id
  description       = local.sg_ingress_rule_description

  referenced_security_group_id = aws_security_group.ecs_backend_services.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
  tags = {
    Name = "allow-${var.full_proj_name}-${var.module_name}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = var.vpc_endpoint_sg_id
  description       = local.sg_ingress_rule_description

  referenced_security_group_id = aws_security_group.ecs_backend_services.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
  tags = {
    Name = "allow-${var.full_proj_name}-${var.module_name}"
  }
}

# redis
resource "aws_vpc_security_group_ingress_rule" "allow_to_redis_connect" {
  security_group_id = var.redis_security_group_id

  description                  = "Allow ${var.module_name}"
  from_port                    = var.redis_port
  to_port                      = var.redis_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_backend_services.id
  tags = {
    Name = "Allow ${var.module_name}"
  }
}