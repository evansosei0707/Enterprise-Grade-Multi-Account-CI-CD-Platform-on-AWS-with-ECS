#------------------------------------------------------------------------------
# ECR Repository - Container Registry
#------------------------------------------------------------------------------

resource "aws_ecr_repository" "inventory_api" {
  name                 = "${var.project_name}-inventory-api"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name    = "${var.project_name}-inventory-api"
    Purpose = "Container Image Repository"
  }
}

#------------------------------------------------------------------------------
# ECR Lifecycle Policy - Keep recent images, cleanup old ones
#------------------------------------------------------------------------------

resource "aws_ecr_lifecycle_policy" "inventory_api" {
  repository = aws_ecr_repository.inventory_api.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 20 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 20
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

#------------------------------------------------------------------------------
# ECR Repository Policy - Cross-Account Pull Access
#------------------------------------------------------------------------------

resource "aws_ecr_repository_policy" "inventory_api" {
  repository = aws_ecr_repository.inventory_api.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowWorkloadAccountsPull"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${var.dev_account_id}:root",
            "arn:aws:iam::${var.staging_account_id}:root",
            "arn:aws:iam::${var.prod_account_id}:root"
          ]
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories"
        ]
      }
    ]
  })
}
