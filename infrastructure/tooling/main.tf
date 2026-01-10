#------------------------------------------------------------------------------
# Tooling Account - Main Module Orchestration
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# KMS Module - Encryption Keys
#------------------------------------------------------------------------------

module "kms" {
  source = "./kms"

  project_name       = var.project_name
  aws_region         = var.aws_region
  tooling_account_id = var.tooling_account_id
  dev_account_id     = var.dev_account_id
  staging_account_id = var.staging_account_id
  prod_account_id    = var.prod_account_id
}

#------------------------------------------------------------------------------
# S3 Module - Terraform State and Artifacts Buckets
#------------------------------------------------------------------------------

module "s3" {
  source = "./s3"

  project_name       = var.project_name
  tooling_account_id = var.tooling_account_id
  dev_account_id     = var.dev_account_id
  staging_account_id = var.staging_account_id
  prod_account_id    = var.prod_account_id
  kms_key_arn        = module.kms.kms_key_arn
}

#------------------------------------------------------------------------------
# DynamoDB Module - Terraform State Locking
#------------------------------------------------------------------------------

module "dynamodb" {
  source = "./dynamodb"

  project_name = var.project_name
}

#------------------------------------------------------------------------------
# ECR Module - Container Registry
#------------------------------------------------------------------------------

module "ecr" {
  source = "./ecr"

  project_name       = var.project_name
  aws_region         = var.aws_region
  tooling_account_id = var.tooling_account_id
  dev_account_id     = var.dev_account_id
  staging_account_id = var.staging_account_id
  prod_account_id    = var.prod_account_id
}
