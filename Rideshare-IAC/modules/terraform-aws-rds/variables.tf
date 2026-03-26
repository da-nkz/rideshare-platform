variable "prefix" {
  description = "Resource naming prefix (e.g., teleios-daniel-dev)"
  type = string
}
 
variable "vpc_id" {
  description = "VPC ID from the VPC module output"
  type = string
}
 
variable "vpc_cidr" {
  description = "VPC CIDR - used to scope the DB security group"
  type = string
}
 
variable "subnet_ids" {
  description = "Private subnet IDs for the DB subnet group"
  type = list(string)
}
 
variable "instance_class" {
  description = "RDS instance class"
  type = string
  default = "db.t3.micro"
}
 
variable "db_name" {
  description = "Name of the initial database"
  type = string
}
 
variable "db_username" {
  description = "Master DB username"
  type = string
  sensitive = true
}
 
variable "db_password" {
  description = "Master DB password"
  type = string
  sensitive = true
}
 
variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type = bool
  default = false
}
 
variable "backup_retention_period" {
  description = "Days to retain automated backups"
  type = number
  default = 7
}
 
variable "storage_encrypted" {
  description = "Enable storage encryption at rest"
  type = bool
  default = true
}
 
variable "tags" {
  description = "Additional tags to apply to all resources"
  type = map(string)
  default = {}
}

