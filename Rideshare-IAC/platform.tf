# ── platform.tf ───────────────────────────────────────────────────
#
# Installs the Kubernetes platform tooling on top of the EKS cluster.
# All resources here depend on the EKS node group being fully ready
# so that pods can actually be scheduled before helm marks installs
# as complete.
#
# Components:
#   1. NGINX Ingress Controller  — routes external traffic into cluster
#   2. Cert-Manager              — TLS certificates from Let's Encrypt
#   3. External Secrets Operator — syncs AWS Secrets Manager → K8s Secrets
#   4. ExternalDNS               — auto-creates Route 53 DNS records
#
# IRSA (IAM Roles for Service Accounts) for ESO and ExternalDNS are
# also created here so pods can authenticate to AWS without static keys.

locals {
  oidc_host = trimprefix(module.eks.oidc_provider_url, "https://")
}

# ── IRSA: External Secrets Operator ───────────────────────────────
# Allows the ESO pod to call AWS Secrets Manager using its Kubernetes
# identity — no static AWS keys stored in the cluster.
resource "aws_iam_role" "external_secrets" {
  name = "teleios-${var.student_name}-${var.environment}-external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = module.eks.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_host}:sub" = "system:serviceaccount:external-secrets:external-secrets-sa"
          "${local.oidc_host}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# ── IRSA: ExternalDNS ─────────────────────────────────────────────
# Allows the ExternalDNS pod to upsert records in Route 53.
resource "aws_iam_policy" "external_dns" {
  name = "teleios-${var.student_name}-${var.environment}-external-dns-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["route53:ChangeResourceRecordSets"]
        Resource = "arn:aws:route53:::hostedzone/*"
      },
      {
        Effect   = "Allow"
        Action   = ["route53:ListHostedZones", "route53:ListResourceRecordSets"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "external_dns" {
  name = "teleios-${var.student_name}-${var.environment}-external-dns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = module.eks.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_host}:sub" = "system:serviceaccount:external-dns:external-dns"
          "${local.oidc_host}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

# ── 1. NGINX Ingress Controller ────────────────────────────────────
# Provisions an AWS NLB and routes external traffic into the cluster.
# Admission webhooks disabled to prevent stuck hook jobs on re-runs.
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  wait             = true
  timeout          = 300

  set {
    name  = "controller.admissionWebhooks.enabled"
    value = "false"
  }

  depends_on = [module.eks]
}

# ── 2. Cert-Manager ───────────────────────────────────────────────
# Automatically provisions and renews TLS certificates from
# Let's Encrypt for daniel.teleioslabs.net.
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  wait             = true
  timeout          = 300

  set {
    name  = "crds.enabled"
    value = "true"
  }

  depends_on = [module.eks]
}

# ── 3. External Secrets Operator ──────────────────────────────────
# Syncs secrets from AWS Secrets Manager into Kubernetes Secrets
# so pods can read them as environment variables.
# The service account is annotated with the IRSA role ARN so ESO
# can authenticate to AWS without static credentials.
resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  wait             = true
  timeout          = 300

  set {
    name  = "serviceAccount.name"
    value = "external-secrets-sa"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_secrets.arn
  }

  depends_on = [module.eks, aws_iam_role_policy_attachment.external_secrets]
}

# ── 4. ExternalDNS ────────────────────────────────────────────────
# Watches Ingress resources and automatically upserts a DNS record
# in Route 53 for daniel.teleioslabs.net pointing to the NLB.
resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  chart            = "external-dns"
  namespace        = "external-dns"
  create_namespace = true
  wait             = true
  timeout          = 300

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "domainFilters[0]"
    value = "teleioslabs.net"
  }

  set {
    name  = "policy"
    value = "upsert-only"
  }

  set {
    name  = "txtOwnerId"
    value = "teleios-${var.student_name}-cluster"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_dns.arn
  }

  depends_on = [module.eks, aws_iam_role_policy_attachment.external_dns]
}
