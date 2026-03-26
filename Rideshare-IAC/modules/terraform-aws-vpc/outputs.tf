output "vpc_id" {
  description = "The VPC ID"
  value = aws_vpc.this.id
}
 
output "vpc_cidr" {
  description = "The VPC CIDR block"
  value = aws_vpc.this.cidr_block
}
 
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value = aws_subnet.public[*].id
}
 
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value = aws_subnet.private[*].id
}
 
output "nat_gateway_id" {
  description = "NAT Gateway ID (null if not created)"
  value = length(aws_nat_gateway.this) > 0 ? aws_nat_gateway.this[0].id : null
}
 
output "base_security_group_id" {
  description = "Base networking security group ID"
  value = aws_security_group.base.id
}
 
output "alb_security_group_id" {
  description = "ALB security group ID"
  value = aws_security_group.alb.id
}

