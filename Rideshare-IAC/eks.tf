module "eks" {
  source = "./modules/terraform-aws-eks"
 
  prefix = "teleios-${var.student_name}-${var.environment}"
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids = module.vpc.public_subnet_ids
  cluster_version = var.eks_cluster_version
  node_instance_type = var.eks_node_instance_type
  node_desired_size = var.eks_node_desired_size
  node_min_size = var.eks_node_min_size
  node_max_size = var.eks_node_max_size
  tags = var.tags

  depends_on = [module.vpc]
}

