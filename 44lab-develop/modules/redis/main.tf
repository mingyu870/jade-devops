#################################
### redis subnet group delete no
#################################
resource "aws_elasticache_subnet_group" "redis_sg" {
  name = "${var.full_proj_name}-${var.module_name}-redis-subnet-group"
  subnet_ids = [
    for az_id, subnet in var.private_subnet : subnet.id
  ]

  tags = {
    Name = "redis subnet group-${var.full_proj_name}"
  }
}

#################################
### redis securi group delete no
#################################
resource "aws_security_group" "redis" {
  name        = "${var.full_proj_name}-${var.module_name}-rds-sg"
  description = "${var.full_proj_name}-${var.module_name}-rds-sg"
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
    Name = "${var.full_proj_name}-${var.module_name}-redis-sg"
  }
}

##############################
# rds - instance
##############################
resource "aws_elasticache_replication_group" "redis_instance" {
  replication_group_id       = "rd-${var.full_proj_name}-${var.module_name}-redis-instance"
  description                = "${var.full_proj_name}-${var.module_name}-redis-instance"
  node_type                  = var.redis.node_type
  port                       = 6379
  parameter_group_name       = aws_elasticache_parameter_group.redis_instance_pg.name
  automatic_failover_enabled = false 
  num_node_groups            = var.redis.num_node_groups
  replicas_per_node_group    = var.redis.replicas_per_node_group
  snapshot_retention_limit   = var.redis.snapshot_retention_limit
  snapshot_window            = var.redis.snapshot_window
  security_group_ids         = [aws_security_group.redis.id]
  subnet_group_name          = aws_elasticache_subnet_group.redis_sg.name
  apply_immediately          = true
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_instance_slow_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_instance_engin_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  tags = {
    Name = "redis-${var.module_name}-for-${var.full_proj_name}"
  }
}

resource "aws_elasticache_parameter_group" "redis_instance_pg" {
  name   = "${var.full_proj_name}-${var.module_name}-redis-instance-on"
  family = "redis7"
  parameter {
    name  = "cluster-enabled"
    value = "no"
  }
  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }
}

resource "aws_cloudwatch_log_group" "redis_instance_slow_log" {
  name              = "/aws/elasticache/redis/${var.full_proj_name}/instance-slow-log"
  retention_in_days = 365
}

resource "aws_cloudwatch_log_group" "redis_instance_engin_log" {
  name              = "/aws/elasticache/redis/${var.full_proj_name}/instance-redis-engin-log"
  retention_in_days = 365
}