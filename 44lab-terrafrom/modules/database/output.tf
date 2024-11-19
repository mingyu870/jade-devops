output "rds" {
  value = aws_rds_cluster.rds
}

output "rds_sg" {
  value = aws_security_group.rds
}