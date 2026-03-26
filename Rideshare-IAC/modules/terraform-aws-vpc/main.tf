# ── VPC ──────────────────────────────────────────────────────────
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = merge({ Name = "${var.prefix}-vpc" }, var.tags)
}
 
# ── Internet Gateway ─────────────────────────────────────────────
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge({ Name = "${var.prefix}-igw" }, var.tags)
}
 
# ── Public Subnets ───────────────────────────────────────────────
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
 
  vpc_id = aws_vpc.this.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
 
  tags = merge({
    Name = "${var.prefix}-public-subnet-${count.index + 1}"
    Tier = "public"
  }, var.tags)
}
 
# ── Private Subnets ──────────────────────────────────────────────
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
 
  vpc_id = aws_vpc.this.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
 
  tags = merge({
    Name = "${var.prefix}-private-subnet-${count.index + 1}"
    Tier = "private"
  }, var.tags)
}
 
# ── Public Route Table ───────────────────────────────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge({ Name = "${var.prefix}-public-rt" }, var.tags)
}
 
resource "aws_route" "public_internet" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.this.id
}
 
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
 
# ── NAT Gateway (conditional) ────────────────────────────────────
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags = merge({ Name = "${var.prefix}-nat-eip" }, var.tags)
}
 
resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id = aws_subnet.public[0].id
  tags = merge({ Name = "${var.prefix}-natgw" }, var.tags)
  depends_on = [aws_internet_gateway.this]
}
 
# ── Private Route Table ──────────────────────────────────────────
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = merge({ Name = "${var.prefix}-private-rt" }, var.tags)
}
 
resource "aws_route" "private_nat" {
  count = var.enable_nat_gateway ? 1 : 0
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.this[0].id

  depends_on = [aws_nat_gateway.this]
}
 
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
 
# ── Base Security Group ──────────────────────────────────────────
resource "aws_security_group" "base" {
  name = "${var.prefix}-base-sg"
  description = "Base networking SG - VPC-internal traffic"
  vpc_id = aws_vpc.this.id
 
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow all intra-VPC traffic"
  }
 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = merge({ Name = "${var.prefix}-base-sg" }, var.tags)
}
 
# ── ALB Security Group ───────────────────────────────────────────
resource "aws_security_group" "alb" {
  name = "${var.prefix}-alb-sg"
  description = "ALB SG - HTTP and HTTPS inbound"
  vpc_id = aws_vpc.this.id
 
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
 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = merge({ Name = "${var.prefix}-alb-sg" }, var.tags)
}

