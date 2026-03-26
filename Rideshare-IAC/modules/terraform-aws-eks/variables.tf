variable "prefix" {
  description = "Resource naming prefix (e.g., teleios-daniel-dev)"
  type = string
}
 
variable "vpc_id" {
  description = "VPC ID from the VPC module output"
  type = string
}
 
variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS nodes"
  type = list(string)
}
 
variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type = list(string)
}
 
variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type = string
  default = "1.29"
}
 
variable "node_instance_type" {
  description = "EC2 instance type for EKS managed nodes"
  type = string
  default = "t3.medium"
}
 
variable "node_desired_size" {
  description = "Desired number of nodes"
  type = number
  default = 2
}
 
variable "node_min_size" {
  description = "Minimum number of nodes"
  type = number
  default = 1
}
 
variable "node_max_size" {
  description = "Maximum number of nodes"
  type = number
  default = 4
}
 
variable "tags" {
  description = "Additional tags to apply to all resources"
  type = map(string)
  default = {}
}

