# ── Identity ─────────────────────────────────────────────────────
student_name = "daniel"
environment = "dev"
aws_region = "eu-west-1"
 
tags = {
  Project = "ecommerce"
  Environment = "dev"
  Owner = "daniel"
}
 
# ── VPC - single AZ, no NAT Gateway ─────────────────────────────
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
availability_zones = ["eu-west-1a", "eu-west-1b"]
enable_nat_gateway = true
 
# ── EKS ──────────────────────────────────────────────────────────
eks_cluster_version = "1.33"
eks_node_instance_type = "t3.medium"
eks_node_desired_size = 2
eks_node_min_size = 1
eks_node_max_size = 3
 
# ── EC2 ──────────────────────────────────────────────────────────
ec2_instance_type = "t3.micro"
ec2_ami_id = "ami-047bb4163c506cd98"
ec2_desired_capacity = 1
ec2_min_size = 1
ec2_max_size = 2
 
# ── RDS - no multi-az, minimal backup ────────────────────────────
rds_instance_class = "db.t3.micro"
rds_db_name = "ecommercedb"
# Sensitive variables set in Terraform Cloud workspace (never in this file):
# rds_db_username, rds_db_password, azure_email_connection_string,
# sender_email, google_client_id, google_client_secret, mapbox_access_token
rds_multi_az = false
rds_backup_retention_period = 1
rds_storage_encrypted = false
 
# ── Redis ────────────────────────────────────────────────────────
redis_node_type = "cache.t3.micro"
redis_num_nodes = 1
redis_engine_version = "7.0"

