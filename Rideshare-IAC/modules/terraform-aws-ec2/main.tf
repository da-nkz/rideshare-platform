# ── Security Group ───────────────────────────────────────────────
resource "aws_security_group" "ec2" {
  name = "${var.prefix}-ec2-sg"
  description = "EC2 instance security group"
  vpc_id = var.vpc_id
 
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }
 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = merge({ Name = "${var.prefix}-ec2-sg" }, var.tags)
}
 
# ── Launch Template ──────────────────────────────────────────────
resource "aws_launch_template" "this" {
  name_prefix = "${var.prefix}-lt-"
  image_id = var.ami_id
  instance_type = var.instance_type
 
  network_interfaces {
    associate_public_ip_address = false
    security_groups = [aws_security_group.ec2.id]
  }
 
  tag_specifications {
    resource_type = "instance"
    tags = merge({ Name = "${var.prefix}-web" }, var.tags)
  }
 
  tags = merge({ Name = "${var.prefix}-lt" }, var.tags)
}
 
# ── Auto Scaling Group ───────────────────────────────────────────
resource "aws_autoscaling_group" "this" {
  name = "${var.prefix}-asg"
  desired_capacity = var.desired_capacity
  min_size = var.min_size
  max_size = var.max_size
  vpc_zone_identifier = var.subnet_ids
 
  launch_template {
    id = aws_launch_template.this.id
    version = "$Latest"
  }
 
  health_check_type = "EC2"
  health_check_grace_period = 300
 
  tag {
    key = "Name"
    value = "${var.prefix}-web"
    propagate_at_launch = true
  }
}

