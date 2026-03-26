# ── Security Group ───────────────────────────────────────────────
resource "aws_security_group" "redis" {
  name = "${var.prefix}-redis-sg"
  description = "ElastiCache Redis security group"
  vpc_id = var.vpc_id
 
  ingress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Redis from within VPC only"
  }
 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = merge({ Name = "${var.prefix}-redis-sg" }, var.tags)
}
 
# ── Cache Subnet Group ───────────────────────────────────────────
resource "aws_elasticache_subnet_group" "this" {
  name = "${var.prefix}-cache-subnet-group"
  subnet_ids = var.subnet_ids
  tags = merge({ Name = "${var.prefix}-cache-subnet-group" }, var.tags)
}
 
# ── ElastiCache Replication Group ────────────────────────────────
resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${var.prefix}-redis"
  description = "Redis cluster for ${var.prefix}"
  node_type = var.node_type
  num_cache_clusters = var.num_cache_nodes
  engine_version = var.engine_version
  port = 6379
 
  subnet_group_name = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.redis.id]
  automatic_failover_enabled = var.num_cache_nodes > 1 ? true : false
 
  tags = merge({ Name = "${var.prefix}-redis" }, var.tags)
}

