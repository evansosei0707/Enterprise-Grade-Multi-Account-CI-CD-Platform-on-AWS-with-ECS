#------------------------------------------------------------------------------
# Bootstrap - GitHub OIDC Provider and IAM Role
# Deploy this FIRST with local state to solve bootstrap paradox
# After S3/DynamoDB are created, migrate state to remote backend
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Initially use local backend
  # After bootstrap, migrate to S3 backend
  # backend "local" {
  #   path = "terraform.tfstate"
  # }

   backend "s3" {
     bucket         = "ecs-fargate-cicd-tfstate-472294262990"
     key            = "tooling/bootstrap/terraform.tfstate"
     region         = "us-east-1"
     encrypt        = true
     dynamodb_table = "ecs-fargate-cicd-tfstate-lock"
   }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "tooling"
      ManagedBy   = "Terraform"
      Component   = "bootstrap"
    }
  }
}

#------------------------------------------------------------------------------
# GitHub OIDC Provider
#------------------------------------------------------------------------------

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Name = "${var.project_name}-github-oidc-provider"
  }
}

#------------------------------------------------------------------------------
# GitHub Actions Role - Assumed via OIDC
#------------------------------------------------------------------------------

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    sid     = "GitHubOIDCAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main",
        "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/*",
        "repo:${var.github_org}/${var.github_repo}:pull_request"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.project_name}-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = {
    Name = "${var.project_name}-github-actions-role"
  }
}

#------------------------------------------------------------------------------
# GitHub Actions Role Policy - Cross-Account Access
#------------------------------------------------------------------------------

data "aws_iam_policy_document" "github_actions_policy" {
  # Allow assuming deploy roles in workload accounts
  statement {
    sid    = "AssumeDeployRoles"
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::${var.dev_account_id}:role/*-ci-deploy-role",
      "arn:aws:iam::${var.staging_account_id}:role/*-ci-deploy-role",
      "arn:aws:iam::${var.prod_account_id}:role/*-ci-deploy-role"
    ]
  }

  # ECR permissions for the tooling account
  statement {
    sid    = "ECRAuth"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPushPull"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:ListImages"
    ]
    resources = [
      "arn:aws:ecr:${var.aws_region}:${var.tooling_account_id}:repository/${var.project_name}-*"
    ]
  }

  # S3 permissions for Terraform state and artifacts
  statement {
    sid    = "S3StateAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.project_name}-tfstate-${var.tooling_account_id}",
      "arn:aws:s3:::${var.project_name}-tfstate-${var.tooling_account_id}/*",
      "arn:aws:s3:::${var.project_name}-artifacts-${var.tooling_account_id}",
      "arn:aws:s3:::${var.project_name}-artifacts-${var.tooling_account_id}/*"
    ]
  }

  # DynamoDB permissions for state locking
  statement {
    sid    = "DynamoDBStateLock"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${var.tooling_account_id}:table/${var.project_name}-tfstate-lock"
    ]
  }

  # KMS permissions for encryption
  statement {
    sid    = "KMSAccess"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      "arn:aws:kms:${var.aws_region}:${var.tooling_account_id}:key/*"
    ]
  }
}

resource "aws_iam_role_policy" "github_actions" {
  name   = "${var.project_name}-github-actions-policy"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions_policy.json
}
