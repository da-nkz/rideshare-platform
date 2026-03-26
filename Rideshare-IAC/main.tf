# ── Terraform Cloud Backend ───────────────────────────────────────
terraform {
  required_version = ">= 1.5"

  # Terraform Cloud backend — state is stored and runs are tracked in
  # Terraform Cloud. Set your organization name below.
  # Authentication uses the TF_API_TOKEN GitHub secret (see terraform.yml).
  cloud {
    organization = "Teleios"
    workspaces {
      name = "teleios-daniel-dev"
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