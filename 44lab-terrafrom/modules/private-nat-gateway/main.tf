##############################
# private nat and route table
##############################

resource "aws_eip" "public_nat_ips" {
  for_each = var.public_subnet
  domain   = "vpc"
  tags = {
    Name = "public NAT gateway IP ${each.key}"
  }
}

resource "aws_nat_gateway" "nat" {
  for_each      = aws_eip.public_nat_ips
  allocation_id = each.value.id
  subnet_id     = var.public_subnet[each.key].id
  tags = {
    Name = "private to public NAT gateway ${each.key}"
  }
}

resource "aws_route_table" "private_route_table" {
  for_each = var.private_subnet
  vpc_id   = var.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.key].id
  }
  tags = {
    Name = "private rt ${each.key} ${var.project_name}-${var.env}"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_route_table.private_route_table
  subnet_id      = var.private_subnet[each.key].id
  route_table_id = each.value.id
}