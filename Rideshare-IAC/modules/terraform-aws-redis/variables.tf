variable "prefix" {
  description = "Resource naming prefix (e.g., teleios-daniel-dev)"
  type = string
}
 
variable "vpc_id" {
  description = "VPC ID from the VPC module output"
  type = string
}
 
variable "vpc_cidr" {
  description = "VPC CIDR - used to scope the Redis security group"
  type = string
}
 
variable "subnet_ids" {
  description = "Private subnet IDs for the cache subnet group"
  type = list(string)
}
 
variable "node_type" {
  description = "ElastiCache node type"
  type = string
  default = "cache.t3.micro"
}
 
variable "num_cache_nodes" {
  description = "Number of cache nodes"
  type = number
  default = 1
}
 
variable "engine_version" {
  description = "Redis engine version"
  type = string
  default = "7.0"
}
 
variable "tags" {
  description = "Additional tags to apply to all resources"
  type = map(string)
  default = {}
}

