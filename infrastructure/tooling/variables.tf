#------------------------------------------------------------------------------
# Tooling Account Variables
#------------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "ecs-fargate-cicd"
}

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
  default     = "evansosei0707"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "Enterprise-Grade-Multi-Account-CI-CD-Platform-on-AWS-with-ECS"
}

#------------------------------------------------------------------------------
# Account IDs
#------------------------------------------------------------------------------

variable "tooling_account_id" {
  description = "AWS Account ID for Tooling account"
  type        = string
  default     = "472294262990"
}

variable "dev_account_id" {
  description = "AWS Account ID for Dev account"
  type        = string
  default     = "067847734974"
}

variable "staging_account_id" {
  description = "AWS Account ID for Staging account"
  type        = string
  default     = "956574163435"
}

variable "prod_account_id" {
  description = "AWS Account ID for Prod account"
  type        = string
  default     = "235249476696"
}
