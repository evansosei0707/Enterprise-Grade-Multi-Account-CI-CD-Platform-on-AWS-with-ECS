output "ecs_service_security_group_id" {
  description = "ID of the ECS service security group"
  value       = aws_security_group.ecs_service.id
}

output "ecs_service_security_group_arn" {
  description = "ARN of the ECS service security group"
  value       = aws_security_group.ecs_service.arn
}
