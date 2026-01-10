#------------------------------------------------------------------------------
# AWS Provider Configuration - Dev Environment
# Cross-account access via AssumeRole
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider to assume role in Dev account
provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = var.deploy_role_arn
    session_name = "TerraformDevDeploy"
  }

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Provider for Tooling account (for cross-account data sources)
provider "aws" {
  alias  = "tooling"
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "Terraform"
    }
  }
}
