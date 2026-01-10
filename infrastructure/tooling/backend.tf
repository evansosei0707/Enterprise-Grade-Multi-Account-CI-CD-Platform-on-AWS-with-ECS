#------------------------------------------------------------------------------
# Terraform Backend Configuration - Tooling Account
# Use this AFTER bootstrap is complete and S3/DynamoDB exist
#------------------------------------------------------------------------------

# terraform {
#   backend "s3" {
#     bucket         = "ecs-fargate-cicd-tfstate-472294262990"
#     key            = "tooling/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "ecs-fargate-cicd-tfstate-lock"
#   }
# }
