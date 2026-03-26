module "ec2" {
  source = "./modules/terraform-aws-ec2"
 
  prefix = "teleios-${var.student_name}-${var.environment}"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  instance_type = var.ec2_instance_type
  ami_id = var.ec2_ami_id
  desired_capacity = var.ec2_desired_capacity
  min_size = var.ec2_min_size
  max_size = var.ec2_max_size
  tags = var.tags

  depends_on = [module.vpc]
}

