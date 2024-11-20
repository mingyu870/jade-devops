output "rt" {
  value = aws_route_table.private_route_table
}


output "private_route_table" {
  // k is az
  value = { for k, v in aws_route_table.private_route_table : k => {
    az_id = k
    id    = v.id
    arn   = v.arn
  } }
}

output "public_nat_ips" {
  value = aws_eip.public_nat_ips
}