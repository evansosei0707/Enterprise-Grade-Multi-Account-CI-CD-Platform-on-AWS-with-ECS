#------------------------------------------------------------------------------
# Prod Environment Variables
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
  default     = "prod"
}

variable "tooling_account_id" {
  description = "Tooling account ID"
  type        = string
  default     = "472294262990"
}

variable "prod_account_id" {
  description = "Prod account ID"
  type        = string
  default     = "235249476696"
}

variable "deploy_role_arn" {
  description = "ARN of the deploy role to assume"
  type        = string
  default     = "arn:aws:iam::235249476696:role/prod-ci-deploy-role"
}

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

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}

variable "task_cpu" {
  description = "CPU units for the task"
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Memory for the task in MB"
  type        = number
  default     = 1024
}

# Prod-specific: Higher desired count
variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 2
}

# Prod-specific: 30 days retention
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

# Prod-specific: Autoscaling enabled with higher limits
variable "enable_autoscaling" {
  description = "Enable autoscaling"
  type        = bool
  default     = true
}

variable "min_capacity" {
  description = "Minimum tasks for autoscaling"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum tasks for autoscaling"
  type        = number
  default     = 6
}
