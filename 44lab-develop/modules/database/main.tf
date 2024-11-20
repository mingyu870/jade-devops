##############################
# RDS Parameter Group
##############################
resource "aws_rds_cluster_parameter_group" "rds_cluster_parameter_group" {
  name        = "${var.full_proj_name}-cluster-mysql-8-0"
  family      = "aurora-mysql8.0"  # Aurora MySQL
  description = "Parameter group for Aurora MySQL 8.0 with custom settings for clusters"

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }
  parameter {
    name  = "log_output"
    value = "FILE"
    apply_method = "immediate"
  }

  parameter {
    name  = "general_log"
    value = "1"
  }

  parameter {
    name  = "log_bin_trust_function_creators"
    value = "1"
  }

  parameter {
    name  = "innodb_print_all_deadlocks"
    value = "1"
  }

   parameter {
    name  = "innodb_deadlock_detect"
    value = "ON"
    apply_method = "immediate"
  }
  
  tags = {
    Name = "${var.full_proj_name}-mysql-8-0"
  }
}

##############################
# RDS Instance Parameter Group
##############################
resource "aws_db_parameter_group" "rds_instance_parameter_group" {
  name        = "${var.full_proj_name}-instance-mysql-8-0"
  family      = "aurora-mysql8.0"  # Aurora MySQL
  description = "Parameter group for Aurora MySQL 8.0 instance"

  tags = {
    Name = "${var.full_proj_name}-mysql-8-0-instance"
  }
}

##############################
# Aurora RDS Cluster
##############################
resource "aws_rds_cluster" "rds" {
  cluster_identifier              = "${var.full_proj_name}-${var.module_name}-cluster-rds"
  engine                          = "aurora-mysql" 
  database_name                   = var.db_name
  master_username                 = replace("${var.db_name}-admin", "-", "_")
  master_password                 = var.rds_pwd
  backup_retention_period         = 7
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.rds_cluster_parameter_group.name
  db_subnet_group_name            = aws_db_subnet_group.private.name
  deletion_protection             = !var.force_destroy
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  engine_version                  = "8.0.mysql_aurora.3.07.1"
  vpc_security_group_ids          = [aws_security_group.rds.id]
  performance_insights_enabled    = true  # RDS 클러스터 인사이트 활성화
  skip_final_snapshot             = true
  storage_encrypted               = true
  
  
  tags = {
    Name = "rds-cluster-${var.module_name}-for-${var.full_proj_name}"
  }
}

##############################
# Aurora RDS Cluster Instance
##############################
resource "aws_rds_cluster_instance" "rds_instance" {
  count                           = 1  
  cluster_identifier              = aws_rds_cluster.rds.id
  identifier                      = "${var.full_proj_name}-${var.module_name}-instance-1" 
  instance_class                  = var.instance_type 
  engine                          = "aurora-mysql"  
  db_subnet_group_name            = aws_db_subnet_group.private.name
  db_parameter_group_name         = aws_db_parameter_group.rds_instance_parameter_group.name
  #vpc_security_group_ids          = [aws_security_group.rds.id]
  publicly_accessible             = false  
  apply_immediately               = false
  auto_minor_version_upgrade      = false

  tags = {
    Name = "${var.full_proj_name}-${var.module_name}-rds-instance-${count.index + 1}"
  }
}

##############################
# Aurora RDS Cluster Instance (Read-Only)
##############################
resource "aws_rds_cluster_instance" "rds_read_instance" {
  count                           = 1  
  cluster_identifier              = aws_rds_cluster.rds.id
  identifier                      = "${var.full_proj_name}-${var.module_name}-instance-2" 
  instance_class                  = var.instance_type 
  engine                          = "aurora-mysql"  
  db_subnet_group_name            = aws_db_subnet_group.private.name
  db_parameter_group_name         = aws_db_parameter_group.rds_instance_parameter_group.name
  publicly_accessible             = false  
  apply_immediately               = false
  auto_minor_version_upgrade      = false

  tags = {
    Name = "${var.full_proj_name}-${var.module_name}-rds-instance-${count.index + 1}"
  }
}

resource "aws_db_subnet_group" "private" {
  name = "private-subnet-group"
  subnet_ids = [
    for az_id, subnet in var.private_subnet : subnet.id
  ]

  tags = {
    Name = "private subnet group-${var.full_proj_name}"
  }
}

resource "aws_security_group" "rds" {
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
    Name = "${var.full_proj_name}-${var.module_name}-rds-sg"
  }
}