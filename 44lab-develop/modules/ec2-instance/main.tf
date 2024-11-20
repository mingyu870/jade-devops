##############################
# ec2
##############################
# RSA key of size 4096 bits
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  key_name   = "ec2-bastion.pem"
  public_key = tls_private_key.rsa.public_key_openssh
  tags = {
    Name = "ec2-${var.module_name}-key-pair-${var.full_proj_name}"
  }
}

resource "local_file" "ec2_bastion_key" {
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

resource "aws_vpc_security_group_ingress_rule" "allow_to_redis_connect" {
  security_group_id = var.redis_security_group_id

  description                  = "Allow ec2 bastion"
  from_port                    = var.redis_port
  to_port                      = var.redis_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ec2_sg.id
  tags = {
    Name = "Allow ec2 bastion"
  }
}
