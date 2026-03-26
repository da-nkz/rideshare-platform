output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value = aws_autoscaling_group.this.name
}
 
output "launch_template_id" {
  description = "Launch template ID"
  value = aws_launch_template.this.id
}
 
output "security_group_id" {
  description = "EC2 instance security group ID"
  value = aws_security_group.ec2.id
}

