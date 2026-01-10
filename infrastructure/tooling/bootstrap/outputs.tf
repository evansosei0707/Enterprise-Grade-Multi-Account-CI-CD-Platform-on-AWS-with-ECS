#------------------------------------------------------------------------------
# Bootstrap Outputs
#------------------------------------------------------------------------------

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC Provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM Role"
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM Role"
  value       = aws_iam_role.github_actions.name
}
