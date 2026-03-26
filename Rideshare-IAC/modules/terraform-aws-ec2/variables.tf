variable "prefix" {
  description = "Resource naming prefix (e.g., teleios-daniel-dev)"
  type = string
}
 
variable "vpc_id" {
  description = "VPC ID from the VPC module output"
  type = string
}
 
variable "subnet_ids" {
  description = "Subnet IDs to launch instances into"
  type = list(string)
}
 
variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t3.micro"
}
 
variable "ami_id" {
  description = "AMI ID for the instances"
  type = string
}
 
variable "desired_capacity" {
  description = "Desired number of EC2 instances"
  type = number
  default = 1
}
 
variable "min_size" {
  description = "Minimum number of instances"
  type = number
  default = 1
}
 
variable "max_size" {
  description = "Maximum number of instances"
  type = number
  default = 3
}
 
variable "tags" {
  description = "Additional tags to apply to all resources"
  type = map(string)
  default = {}
}

