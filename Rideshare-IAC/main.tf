# ── Terraform Cloud Backend ───────────────────────────────────────
terraform {
  required_version = ">= 1.5"

  # Terraform Cloud backend — state is stored and runs are tracked in
  # Terraform Cloud. Set your organization name below.
  # Authentication uses the TF_API_TOKEN GitHub secret (see terraform.yml).
  cloud {
    organization = "Teleios"
    workspaces {
      tags = ["rideshare"]
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# ── AWS Provider ──────────────────────────────────────────────────
provider "aws" {
  region = var.aws_region
}

# ── Helm Provider ─────────────────────────────────────────────────
# Configured with EKS cluster outputs so helm can talk to the cluster.
# Uses exec to fetch a fresh AWS token at apply time — avoids the
# 15-minute token expiry that affects long applies.
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
    }
  }
}

# ── Kubernetes Provider ────────────────────────────────────────────
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
  }
}