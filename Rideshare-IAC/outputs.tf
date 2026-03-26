# ── VPC ──────────────────────────────────────────────────────────
output "vpc_id" {
  description = "VPC ID"
  value = module.vpc.vpc_id
}
 
output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = module.vpc.public_subnet_ids
}
 
output "private_subnet_ids" {
  description = "Private subnet IDs"
  value = module.vpc.private_subnet_ids
}
 
# ── EKS ──────────────────────────────────────────────────────────
output "eks_cluster_name" {
  description = "EKS cluster name"
  value = module.eks.cluster_name
}
 
output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value = module.eks.cluster_endpoint
}
 
# ── RDS ──────────────────────────────────────────────────────────
output "rds_endpoint" {
  description = "RDS connection endpoint"
  value = module.rds.db_endpoint
}
 
# ── Redis ────────────────────────────────────────────────────────
output "redis_endpoint" {
  description = "Redis primary endpoint"
  value = module.redis.redis_endpoint
}
 
# ── S3 ───────────────────────────────────────────────────────────
output "s3_bucket_ids" {
  description = "S3 bucket IDs"
  value = module.s3.bucket_ids
}

# ── Secrets Manager ───────────────────────────────────────────────
output "secret_arn_database_url" {
  description = "ARN of the daniel-database-url secret"
  value       = aws_secretsmanager_secret.database_url.arn
}

output "secret_arn_jwt" {
  description = "ARN of the JWT secret"
  value       = aws_secretsmanager_secret.jwt_secret.arn
}

output "secret_arn_email_service" {
  description = "ARN of the email-service secret"
  value       = aws_secretsmanager_secret.email_service.arn
}

output "secret_arn_google_oauth" {
  description = "ARN of the Google OAuth secret"
  value       = aws_secretsmanager_secret.google_oauth.arn
}

output "secret_arn_mapbox" {
  description = "ARN of the Mapbox secret"
  value       = aws_secretsmanager_secret.mapbox.arn
}

