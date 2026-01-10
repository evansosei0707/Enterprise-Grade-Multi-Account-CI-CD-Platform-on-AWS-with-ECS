output "repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.inventory_api.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.inventory_api.arn
}

output "repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.inventory_api.name
}

output "registry_id" {
  description = "Registry ID (account ID)"
  value       = aws_ecr_repository.inventory_api.registry_id
}
