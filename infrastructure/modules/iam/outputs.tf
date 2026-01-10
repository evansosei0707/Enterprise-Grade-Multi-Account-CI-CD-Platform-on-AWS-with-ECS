output "task_execution_role_arn" {
  description = "ARN of the ECS Task Execution Role"
  value       = aws_iam_role.task_execution_role.arn
}

output "task_execution_role_name" {
  description = "Name of the ECS Task Execution Role"
  value       = aws_iam_role.task_execution_role.name
}

output "task_role_arn" {
  description = "ARN of the ECS Task Role"
  value       = aws_iam_role.task_role.arn
}

output "task_role_name" {
  description = "Name of the ECS Task Role"
  value       = aws_iam_role.task_role.name
}
