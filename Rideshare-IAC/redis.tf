module "redis" {
  source = "./modules/terraform-aws-redis"
 
  prefix = "teleios-${var.student_name}-${var.environment}"
  vpc_id = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr
  subnet_ids = module.vpc.private_subnet_ids
  node_type = var.redis_node_type
  num_cache_nodes = var.redis_num_nodes
  engine_version = var.redis_engine_version
  tags = var.tags

  depends_on = [module.vpc]
}

