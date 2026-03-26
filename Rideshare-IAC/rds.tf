module "rds" {
  source = "./modules/terraform-aws-rds"
 
  prefix = "teleios-${var.student_name}-${var.environment}"
  vpc_id = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr
  subnet_ids = module.vpc.private_subnet_ids
  instance_class = var.rds_instance_class
  db_name = var.rds_db_name
  db_username = var.rds_db_username
  db_password = var.rds_db_password
  multi_az = var.rds_multi_az
  backup_retention_period = var.rds_backup_retention_period
  storage_encrypted = var.rds_storage_encrypted
  tags = var.tags

  depends_on = [module.vpc]
}

