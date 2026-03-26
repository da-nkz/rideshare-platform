# ── Identity ─────────────────────────────────────────────────────
variable "student_name" {
  description = "Your first name - used in all resource names"
  type = string
}
 
variable "environment" {
  description = "Environment name: dev | staging | prod"
  type = string
  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod."
  }
}
 
variable "aws_region" {
  description = "AWS region to deploy into"
  type = string
  default = "us-east-1"
}
 
variable "tags" {
  description = "Tags to apply to all resources"
  type = map(string)
  default = {}
}
 
# ── VPC ──────────────────────────────────────────────────────────
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type = string
}
 
variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type = list(string)
}
 
variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type = list(string)
}
 
variable "availability_zones" {
  description = "List of AZs to deploy into"
  type = list(string)
}
 
variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway"
  type = bool
  default = true
}
 
# ── EKS ──────────────────────────────────────────────────────────
variable "eks_cluster_version" {
  description = "Kubernetes version"
  type = string
  default = "1.29"
}
 
variable "eks_node_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type = string
}
 
variable "eks_node_desired_size" { type = number }
variable "eks_node_min_size" { type = number }
variable "eks_node_max_size" { type = number }
 
# ── EC2 ──────────────────────────────────────────────────────────
variable "ec2_instance_type" { type = string }
variable "ec2_ami_id" { type = string }
variable "ec2_desired_capacity" { type = number }
variable "ec2_min_size" { type = number }
variable "ec2_max_size" { type = number }
 
# ── RDS ──────────────────────────────────────────────────────────
variable "rds_instance_class" { type = string }
variable "rds_db_name" { type = string }
variable "rds_db_username" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.rds_db_username) >= 1
    error_message = "rds_db_username is empty — set it in Terraform Cloud workspace variables."
  }
}
variable "rds_db_password" {
  type      = string
  sensitive = true
  validation {
    condition     = length(var.rds_db_password) >= 8
    error_message = "rds_db_password is empty or too short — must be at least 8 characters."
  }
}
variable "rds_multi_az" { type = bool }
variable "rds_backup_retention_period" { type = number }
variable "rds_storage_encrypted" { type = bool }
 
# ── Redis ────────────────────────────────────────────────────────
variable "redis_node_type" { type = string }
variable "redis_num_nodes" { type = number }
variable "redis_engine_version" {
    type = string
    default = "7.0"
     }

# ── External Service Credentials ─────────────────────────────────
# These are set as sensitive variables in Terraform Cloud — never
# committed to tfvars files. Terraform writes them into AWS Secrets
# Manager during apply so pods can read them at runtime.

variable "azure_email_connection_string" {
  description = "Azure Communication Services connection string for email-service"
  type        = string
  sensitive   = true
}

variable "sender_email" {
  description = "Sender email address for Azure Communication Services"
  type        = string
}

variable "google_client_id" {
  description = "Google OAuth 2.0 client ID for rider-service"
  type        = string
}

variable "google_client_secret" {
  description = "Google OAuth 2.0 client secret for rider-service"
  type        = string
  sensitive   = true
}

variable "mapbox_access_token" {
  description = "Mapbox public access token for the frontend"
  type        = string
  sensitive   = true
}

