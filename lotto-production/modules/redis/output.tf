output "redis_sg" {
  value = aws_security_group.redis
}

output "redis" {
  value     = aws_elasticache_replication_group.redis_instance
  sensitive = true
}

output "redis_endpoint" {
  value = aws_elasticache_replication_group.redis_instance.configuration_endpoint_address
}