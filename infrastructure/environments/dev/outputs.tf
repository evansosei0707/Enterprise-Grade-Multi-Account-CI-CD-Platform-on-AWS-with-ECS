#------------------------------------------------------------------------------
# Dev Environment Outputs
#------------------------------------------------------------------------------

# Cluster
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_cluster.cluster_arn
}

# Service
output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs_service.service_name
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = module.ecs_service.task_definition_arn
}

# ALB
output "alb_dns_name" {
  description = "DNS name of the ALB (use this to access the application)"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = module.alb.alb_arn
}

# DynamoDB
output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.dynamodb.table_name
}

# Logging
output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.logging.log_group_name
}
