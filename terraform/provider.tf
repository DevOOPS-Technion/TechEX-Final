# ============================================
# Terraform Configuration and Provider
# ============================================
# Configured for AWS Academy (uses session token)

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.6.1"
    }
  }
}

# AWS Provider - credentials from environment variables or GitHub secrets
# AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "TechEX"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
