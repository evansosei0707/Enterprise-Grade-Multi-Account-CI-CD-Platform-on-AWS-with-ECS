variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "tooling_account_id" {
  description = "Tooling account ID"
  type        = string
}

variable "dev_account_id" {
  description = "Dev account ID"
  type        = string
}

variable "staging_account_id" {
  description = "Staging account ID"
  type        = string
}

variable "prod_account_id" {
  description = "Prod account ID"
  type        = string
}
