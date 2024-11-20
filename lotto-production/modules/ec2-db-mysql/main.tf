##############################
# ec2 - IAM
##############################
resource "aws_iam_role" "cw_agent_role" {
  name = "CWAgentRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid = ""
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cw_agent_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.cw_agent_role.name
}

resource "aws_iam_role_policy_attachment" "cw_agent_admin_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
  role       = aws_iam_role.cw_agent_role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  role       = aws_iam_role.cw_agent_role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_full_access_v2" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccessV2"
  role       = aws_iam_role.cw_agent_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.cw_agent_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_full_access_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.cw_agent_role.name
}

resource "aws_iam_instance_profile" "cw_agent_profile" {
  name = "CWAgentInstanceProfile"
  role = aws_iam_role.cw_agent_role.name
}


##############################
# ec2 - key
##############################
# RSA key of size 4096 bits
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  key_name   = "db-mysql.pem"
  public_key = tls_private_key.rsa.public_key_openssh
  tags = {
    Name = "ec2-${var.module_name}-key-pair-${var.full_proj_name}"
  }
}

resource "local_file" "ec2_db_mysql_key" {
  filename        = "ec2-${var.module_name}.pem"
  content         = tls_private_key.rsa.private_key_pem
  file_permission = 400
}

resource "random_shuffle" "private_subnet_id" {
  input = [
    for az_id, subnet in var.private_subnet : subnet.id
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
  subnet_id              = "subnet-0e2b20392e01f3a1a"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.cw_agent_profile.name
  
   # IMDSv2 설정 추가
  metadata_options {
    http_tokens = "required"  # IMDSv2 사용
    http_put_response_hop_limit = 1  # 기본값
  }

  associate_public_ip_address = false
  
  # EBS Volume Configuration
  root_block_device {
    volume_size = 200  # Size in GB
    volume_type = "gp3"  # General Purpose SSD
    encrypted   = false  # Enable encryption
    tags = {
    Name = "mysql-vol" 
    }
  }
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

resource "aws_vpc_security_group_ingress_rule" "allow_to_redis_connect" {
  security_group_id = var.redis_security_group_id

  description                  = "Allow ec2 db_mysql"
  from_port                    = var.redis_port
  to_port                      = var.redis_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ec2_sg.id
  tags = {
    Name = "Allow ec2 db_mysql"
  }
}
##############################
# Target Group
##############################
resource "aws_lb_target_group" "mysql_target_group" {
  name     = "${var.full_proj_name}-mysql-tg"
  port     = 3306
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    protocol           = "TCP"
    port               = "3306"
  }

  tags = {
    Name = "${var.full_proj_name}-mysql-tg"
  }
}

##############################
# Target Group Attachment
##############################
resource "aws_lb_target_group_attachment" "mysql_target_group_attachment" {
  target_group_arn = aws_lb_target_group.mysql_target_group.arn
  target_id        = aws_instance.ec2.id
  port             = 3306
}

##############################
# NLB Security Group
##############################
resource "aws_security_group" "mysql_nlb_sg" {
  name        = "${var.full_proj_name}-mysql-nlb-sg"
  description = "Security group for MySQL NLB"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 필요에 따라 CIDR 블록을 수정하세요.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.full_proj_name}-mysql-nlb-sg"
  }
}

##############################
# NLB
##############################
resource "aws_lb" "mysql_nlb" {
  name               = "${var.full_proj_name}-mysql-nlb"
  internal           = true  
  load_balancer_type = "network"
  security_groups    = [aws_security_group.mysql_nlb_sg.id]  

  enable_deletion_protection = false

  subnet_mapping {
    subnet_id = "subnet-0e2b20392e01f3a1a"  
  }

  tags = {
    Name = "${var.full_proj_name}-mysql-nlb"
  }
}

##############################
# NLB Listener
##############################
resource "aws_lb_listener" "mysql_listener" {
  load_balancer_arn = aws_lb.mysql_nlb.arn
  port              = 3306
  protocol          = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.mysql_target_group.arn
  }
}



# setup install
#sudo yum install amazon-cloudwatch-agent
#vi /opt/aws/amazon-cloudwatch-agent/bin/config.json -> in README.md file
#sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

###############################
## EC2 cloudwatch triggers
##############################
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "${var.module_name}-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = "60"
  statistic          = "Average"
  threshold          = 70
  alarm_description  = "This alarm triggers when CPU exceeds 70%."
  dimensions = {
    InstanceId = aws_instance.ec2.id
  }
  alarm_actions = ["arn:aws:sns:ap-southeast-1:961341522940:llg-production-resource-alarm-topic"] 
}

resource "aws_cloudwatch_metric_alarm" "memory_alarm" {
  alarm_name          = "${var.module_name}-memory-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "mem_used_percent"
  namespace          = "CWAgent"
  period             = "60"
  statistic          = "Average"
  threshold          = 70
  alarm_description  = "This alarm triggers when memory exceeds 70%."
  dimensions = {
    InstanceId = aws_instance.ec2.id
  }
  alarm_actions = ["arn:aws:sns:ap-southeast-1:961341522940:llg-production-resource-alarm-topic"] 
}

##############################
# CloudWatch Alarm for NLB Healthy Hosts
##############################
resource "aws_cloudwatch_metric_alarm" "nlb_health_alarm" {
  alarm_name          = "${var.module_name}-nlb-health-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "HealthyHostCount"
  namespace          = "AWS/NetworkELB"
  period             = "60"
  statistic          = "Average"
  threshold          = 1  
  alarm_description  = "This alarm triggers when there are no healthy hosts in the NLB."
  dimensions = {
    LoadBalancer = "net/llg-production-mysql-nlb/48d99c4abd4c20ad" 
    TargetGroup  = "targetgroup/llg-production-mysql-tg/c70e0d9081bd4a8f"  
  }
  alarm_actions = ["arn:aws:sns:ap-southeast-1:961341522940:llg-production-resource-alarm-topic"]
}

##############################
# CloudWatch Alarm for EC2 Status Check Failures
##############################
resource "aws_cloudwatch_metric_alarm" "ec2_status_alarm" {
  alarm_name          = "${var.module_name}-ec2-status-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "StatusCheckFailed"
  namespace          = "AWS/EC2"
  period             = "60"
  statistic          = "Sum"
  threshold          = 0  # StatusCheckFailed가 0 초과일 때 알람 발생
  alarm_description  = "This alarm triggers when the EC2 instance status check fails."
  dimensions = {
    InstanceId = aws_instance.ec2.id 
  }
  alarm_actions = ["arn:aws:sns:ap-southeast-1:961341522940:llg-production-resource-alarm-topic"]
}
