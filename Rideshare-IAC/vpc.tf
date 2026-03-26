module "vpc" {
  source = "./modules/terraform-aws-vpc"
  # Once published to TF Cloud registry, replace with:
  # source  = "app.terraform.io/teleios-devops/vpc/aws"
  # version = "1.0.0"

  # Builds: teleios-daniel-dev
  prefix = "teleios-${var.student_name}-${var.environment}"

  # From dev.tfvars
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  enable_nat_gateway   = var.enable_nat_gateway
  tags                 = var.tags
}