##############################
# private vpc endpoints
##############################

# vpc endpoints
## s3
resource "aws_vpc_endpoint" "s3" {
  service_name    = "com.amazonaws.${var.region}.s3"
  vpc_id          = var.vpc_id
  route_table_ids = [for v in values(var.private_route_table) : v.id]
  tags = {
    Name = "s3 vpce ${var.full_proj_name}"
  }
}

## ecr-api
resource "aws_vpc_endpoint" "ecr-api" {
  service_name       = "com.amazonaws.${var.region}.ecr.api"
  vpc_id             = var.vpc_id
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  subnet_ids = [
    for az_id, subnet in var.private_subnet : subnet.id
    if !contains(var.exclude_ecr_vpce_subnet_az, az_id)
  ]
  tags = {
    Name = "ecr api vpce ${var.full_proj_name}"
  }
}

### ecr-dkr
resource "aws_vpc_endpoint" "ecr-dkr" {
  service_name       = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_id             = var.vpc_id
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  subnet_ids = [
    for az_id, subnet in var.private_subnet : subnet.id
    if !contains(var.exclude_ecr_vpce_subnet_az, az_id)
  ]
  tags = {
    Name = "ecr dkr vpce ${var.full_proj_name}"
  }
}

## logs
resource "aws_vpc_endpoint" "logs" {
  service_name       = "com.amazonaws.${var.region}.logs"
  vpc_id             = var.vpc_id
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  subnet_ids = [
    for az_id, subnet in var.private_subnet : subnet.id
    #    if !contains(var.exclude_ecr_api_vpce_subnet_az, az_id)
  ]
  tags = {
    Name = "logs vpce ${var.full_proj_name}"
  }
}

## ssm
resource "aws_vpc_endpoint" "ssm" {
  service_name       = "com.amazonaws.${var.region}.ssm"
  vpc_id             = var.vpc_id
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  subnet_ids = [
    for az_id, subnet in var.private_subnet : subnet.id
    #    if !contains(var.exclude_ecr_api_vpce_subnet_az, az_id)
  ]
  tags = {
    Name = "ssm vpce ${var.full_proj_name}"
  }
}

## secrets-manager
resource "aws_vpc_endpoint" "secrets-manager" {
  service_name       = "com.amazonaws.${var.region}.secretsmanager"
  vpc_id             = var.vpc_id
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoints.id]
  subnet_ids = [
    for az_id, subnet in var.private_subnet : subnet.id
    #    if !contains(var.exclude_ecr_api_vpce_subnet_az, az_id)
  ]
  tags = {
    Name = "secrets manager vpce ${var.full_proj_name}"
  }
}

# security group for vpc endpoints(s3, ecr, logs, ssm, secrets-manager)
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.full_proj_name}-vpc-endpoint-sg"
  description = "${var.full_proj_name}-vpc-endpoint-sg"
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
    Name = "${var.full_proj_name}-vpc-endpoint-sg"
  }
}