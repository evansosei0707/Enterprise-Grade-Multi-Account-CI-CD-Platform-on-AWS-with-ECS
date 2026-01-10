variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "tooling_account_id" {
  description = "Tooling account ID for cross-account ECR access"
  type        = string
}
