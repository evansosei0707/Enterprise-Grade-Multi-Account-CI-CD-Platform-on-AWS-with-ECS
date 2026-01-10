#------------------------------------------------------------------------------
# Tooling Account Outputs
#------------------------------------------------------------------------------

# KMS Outputs
output "kms_key_arn" {
  description = "ARN of the KMS key for encryption"
  value       = module.kms.kms_key_arn
}

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = module.kms.kms_key_id
}

# S3 Outputs
output "terraform_state_bucket_name" {
  description = "Name of the Terraform state bucket"
  value       = module.s3.terraform_state_bucket_name
}

output "terraform_state_bucket_arn" {
  description = "ARN of the Terraform state bucket"
  value       = module.s3.terraform_state_bucket_arn
}

output "artifacts_bucket_name" {
  description = "Name of the artifacts bucket"
  value       = module.s3.artifacts_bucket_name
}

output "artifacts_bucket_arn" {
  description = "ARN of the artifacts bucket"
  value       = module.s3.artifacts_bucket_arn
}

# DynamoDB Outputs
output "dynamodb_table_name" {
  description = "Name of the DynamoDB state lock table"
  value       = module.dynamodb.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB state lock table"
  value       = module.dynamodb.dynamodb_table_arn
}

# ECR Outputs
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr.repository_arn
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}
