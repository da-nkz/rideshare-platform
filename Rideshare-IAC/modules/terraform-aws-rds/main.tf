# ── Security Group ───────────────────────────────────────────────
resource "aws_security_group" "rds" {
  name = "${var.prefix}-rds-sg"
  description = "RDS PostgreSQL security group"
  vpc_id = var.vpc_id
 
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "PostgreSQL from within VPC only"
  }
 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = merge({ Name = "${var.prefix}-rds-sg" }, var.tags)
}
 
# ── DB Subnet Group ──────────────────────────────────────────────
resource "aws_db_subnet_group" "this" {
  name = "${var.prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids
  tags = merge({ Name = "${var.prefix}-db-subnet-group" }, var.tags)
}
 
# ── RDS Instance ─────────────────────────────────────────────────
resource "aws_db_instance" "this" {
  identifier = "${var.prefix}-rds"
  engine = "postgres"
  engine_version = "15"
  instance_class = var.instance_class
  allocated_storage = 20
  storage_type = "gp2"
 
  db_name = var.db_name
  username = var.db_username
  password = var.db_password
 
  multi_az = var.multi_az
  backup_retention_period = var.backup_retention_period
  storage_encrypted = var.storage_encrypted
 
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
 
  skip_final_snapshot = true
  deletion_protection = false
 
  tags = merge({ Name = "${var.prefix}-rds" }, var.tags)
}

