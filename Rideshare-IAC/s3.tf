module "s3" {
  source = "./modules/terraform-aws-s3"
 
  prefix = "teleios-${var.student_name}-${var.environment}"
  tags = var.tags

  depends_on = [module.vpc]
}

