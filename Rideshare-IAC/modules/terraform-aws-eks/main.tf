# ── IAM Role - Cluster ───────────────────────────────────────────
resource "aws_iam_role" "cluster" {
  name = "${var.prefix}-eks-cluster-role"
 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
 
  tags = merge({ Name = "${var.prefix}-eks-cluster-role" }, var.tags)
}
 
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
 
# ── IAM Role - Node Group ────────────────────────────────────────
resource "aws_iam_role" "node" {
  name = "${var.prefix}-eks-node-role"
 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
 
  tags = merge({ Name = "${var.prefix}-eks-node-role" }, var.tags)
}
 
locals {
  node_policies = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])
}
 
resource "aws_iam_role_policy_attachment" "node" {
  for_each = local.node_policies
  role = aws_iam_role.node.name
  policy_arn = each.value
}
 
# ── Cluster Security Group ───────────────────────────────────────
resource "aws_security_group" "cluster" {
  name = "${var.prefix}-eks-cluster-sg"
  description = "EKS cluster security group"
  vpc_id = var.vpc_id
 
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    self = true
  }
 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = merge({ Name = "${var.prefix}-eks-cluster-sg" }, var.tags)
}
 
# ── Node Security Group ──────────────────────────────────────────
resource "aws_security_group" "node" {
  name = "${var.prefix}-eks-node-sg"
  description = "EKS node group security group"
  vpc_id = var.vpc_id
 
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [aws_security_group.cluster.id]
  }
 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags = merge({ Name = "${var.prefix}-eks-node-sg" }, var.tags)
}
 
# ── EKS Cluster ──────────────────────────────────────────────────
resource "aws_eks_cluster" "this" {
  name = "${var.prefix}-eks"
  role_arn = aws_iam_role.cluster.arn
  version = var.cluster_version
 
  vpc_config {
    subnet_ids = var.private_subnet_ids
    security_group_ids = [aws_security_group.cluster.id]
    endpoint_private_access = true
    endpoint_public_access = true
  }
 
  depends_on = [aws_iam_role_policy_attachment.cluster_policy]
  tags = merge({ Name = "${var.prefix}-eks" }, var.tags)
}
 
# ── Managed Node Group ───────────────────────────────────────────
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.prefix}-node-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = [var.node_instance_type]
  ami_type        = "AL2023_x86_64_STANDARD"
  capacity_type   = "ON_DEMAND"
  disk_size       = 20

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node,
    aws_eks_cluster.this
  ]

  tags = merge({ Name = "${var.prefix}-node-group" }, var.tags)
}

# ── OIDC Provider ─────────────────────────────────────────────────
data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = merge({ Name = "${var.prefix}-eks-oidc" }, var.tags)
}

# ── VPC CNI Add-on ────────────────────────────────────────────────
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge({ Name = "${var.prefix}-vpc-cni" }, var.tags)
}

# ── CoreDNS Add-on ────────────────────────────────────────────────
resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.this]
  tags       = merge({ Name = "${var.prefix}-coredns" }, var.tags)
}

# ── Kube Proxy Add-on ─────────────────────────────────────────────
resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge({ Name = "${var.prefix}-kube-proxy" }, var.tags)
}

# ── EBS CSI Driver Add-on ─────────────────────────────────────────
resource "aws_iam_role" "ebs_csi" {
  name = "${var.prefix}-ebs-csi-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.this.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = merge({ Name = "${var.prefix}-ebs-csi-role" }, var.tags)
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = aws_iam_role.ebs_csi.arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.this]
  tags       = merge({ Name = "${var.prefix}-ebs-csi" }, var.tags)
}

# ── Metrics Server Add-on ─────────────────────────────────────────
resource "aws_eks_addon" "metrics_server" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "metrics-server"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.this]
  tags       = merge({ Name = "${var.prefix}-metrics-server" }, var.tags)
}

# ── Pod Identity Agent Add-on ─────────────────────────────────────
resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "eks-pod-identity-agent"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge({ Name = "${var.prefix}-pod-identity" }, var.tags)
}