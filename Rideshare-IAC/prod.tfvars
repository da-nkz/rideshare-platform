# ── Identity ─────────────────────────────────────────────────────
student_name = "daniel"
environment  = "prod"
aws_region   = "eu-west-1"

tags = {
  Project     = "ecommerce"
  Environment = "prod"
  Owner       = "daniel"
}

# ── VPC - separate CIDR from dev (10.0.0.0/16) and staging (10.1.0.0/16) ──
vpc_cidr             = "10.2.0.0/16"
public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs = ["10.2.10.0/24", "10.2.11.0/24"]
availability_zones   = ["eu-west-1a", "eu-west-1b"]
enable_nat_gateway   = true

# ── EKS ──────────────────────────────────────────────────────────
eks_cluster_version    = "1.33"
eks_node_instance_type = "t3.large"
eks_node_desired_size  = 3
eks_node_min_size      = 2
eks_node_max_size      = 6

# ── EC2 ──────────────────────────────────────────────────────────
ec2_instance_type    = "t3.small"
ec2_ami_id           = "ami-047bb4163c506cd98"
ec2_desired_capacity = 2
ec2_min_size         = 1
ec2_max_size         = 4

# ── RDS - multi-az, encrypted, full backups ───────────────────────
rds_instance_class          = "db.t3.large"
rds_db_name                 = "ecommercedb"
# Sensitive variables set in Terraform Cloud workspace (never in this file):
# rds_db_username, rds_db_password, azure_email_connection_string,
# sender_email, google_client_id, google_client_secret, mapbox_access_token
rds_multi_az                = true
rds_backup_retention_period = 30
rds_storage_encrypted       = true

# ── Redis ────────────────────────────────────────────────────────
redis_node_type      = "cache.t3.small"
redis_num_nodes      = 2
redis_engine_version = "7.0"
