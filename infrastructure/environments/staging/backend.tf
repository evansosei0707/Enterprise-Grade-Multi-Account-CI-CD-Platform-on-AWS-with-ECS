#------------------------------------------------------------------------------
# Terraform Backend Configuration - Staging Environment
#------------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket         = "ecs-fargate-cicd-tfstate-472294262990"
    key            = "environments/staging/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "ecs-fargate-cicd-tfstate-lock"
  }
}
