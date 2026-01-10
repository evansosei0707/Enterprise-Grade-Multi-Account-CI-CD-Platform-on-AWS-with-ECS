#------------------------------------------------------------------------------
# Dev Environment Variables
#------------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "ecs-fargate-cicd"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

#------------------------------------------------------------------------------
# Account IDs
#------------------------------------------------------------------------------

variable "tooling_account_id" {
  description = "Tooling account ID"
  type        = string
  default     = "472294262990"
}

variable "dev_account_id" {
  description = "Dev account ID"
  type        = string
  default     = "067847734974"
}

#------------------------------------------------------------------------------
# Cross-Account Role
#------------------------------------------------------------------------------

variable "deploy_role_arn" {
  description = "ARN of the deploy role to assume"
  type        = string
  default     = "arn:aws:iam::067847734974:role/dev-ci-deploy-role"
}

#------------------------------------------------------------------------------
# Network Configuration (from Day-0 StackSet)
#------------------------------------------------------------------------------

variable "vpc_id" {
  description = "VPC ID from Day-0 StackSet"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs from Day-0 StackSet"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs from Day-0 StackSet"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB Security Group ID from Day-0 StackSet"
  type        = string
}

#------------------------------------------------------------------------------
# ECR Configuration
#------------------------------------------------------------------------------

variable "ecr_repository_url" {
  description = "ECR repository URL from Tooling account"
  type        = string
  default     = "472294262990.dkr.ecr.us-east-1.amazonaws.com/ecs-fargate-cicd-inventory-api"
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

#------------------------------------------------------------------------------
# ECS Configuration
#------------------------------------------------------------------------------

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "CPU units for the task"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory for the task in MB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

#------------------------------------------------------------------------------
# Environment-Specific Settings
#------------------------------------------------------------------------------

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "enable_autoscaling" {
  description = "Enable autoscaling"
  type        = bool
  default     = false
}

variable "min_capacity" {
  description = "Minimum tasks for autoscaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum tasks for autoscaling"
  type        = number
  default     = 2
}
