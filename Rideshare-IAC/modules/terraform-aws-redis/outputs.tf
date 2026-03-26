output "redis_endpoint" {
  description = "Redis primary endpoint"
  value = aws_elasticache_replication_group.this.primary_endpoint_address
}
 
output "redis_port" {
  description = "Redis port"
  value = 6379
}
 
output "security_group_id" {
  description = "Redis security group ID"
  value = aws_security_group.redis.id
}

