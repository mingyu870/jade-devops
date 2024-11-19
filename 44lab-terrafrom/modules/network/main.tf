##############################
# locals
##############################
locals {
  az_map = zipmap(data.aws_availability_zones.available_az.zone_ids, data.aws_availability_zones.available_az.names)
}

##############################
# vpc
##############################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.full_proj_name} VPC"
  }
}

##############################
# subnets
##############################
resource "aws_subnet" "public_subnets" {
  for_each                                    = local.az_map
  vpc_id                                      = aws_vpc.vpc.id
  availability_zone_id                        = each.key
  cidr_block                                  = cidrsubnet(var.vpc_cidr, 4, index(keys(local.az_map), each.key))
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true
  private_dns_hostname_type_on_launch         = "resource-name"
  tags = {
    Name = "public-subnet-${each.value}"
  }
}

resource "aws_subnet" "private_subnets" {
  for_each                                    = local.az_map
  vpc_id                                      = aws_vpc.vpc.id
  availability_zone_id                        = each.key
  cidr_block                                  = cidrsubnet(var.vpc_cidr, 4, index(keys(local.az_map), each.key) + 8)
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true
  private_dns_hostname_type_on_launch         = "resource-name"
  tags = {
    Name = "private-subnet-${each.value}"
  }
}

##############################
# internet gateway
##############################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "public internet gateway"
  }
}

##############################
# route table
##############################
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public route table ${var.full_proj_name}"
  }
}
