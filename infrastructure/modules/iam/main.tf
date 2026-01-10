#------------------------------------------------------------------------------
# IAM Module - ECS Task Execution Role and Task Role
#------------------------------------------------------------------------------

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

#------------------------------------------------------------------------------
# ECS Task Execution Role - Used by ECS to pull images and push logs
#------------------------------------------------------------------------------

resource "aws_iam_role" "task_execution_role" {
  name = "${var.project_name}-${var.environment}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-task-execution-role"
    Environment = var.environment
  }
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "task_execution_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional policy for cross-account ECR access
resource "aws_iam_role_policy" "task_execution_ecr_cross_account" {
  name = "${var.project_name}-${var.environment}-ecr-cross-account"
  role = aws_iam_role.task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRCrossAccountPull"
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "arn:aws:ecr:${data.aws_region.current.name}:${var.tooling_account_id}:repository/${var.project_name}-*"
      },
      {
        Sid    = "ECRAuth"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

#------------------------------------------------------------------------------
# ECS Task Role - Used by the application for AWS service access
#------------------------------------------------------------------------------

resource "aws_iam_role" "task_role" {
  name = "${var.project_name}-${var.environment}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-task-role"
    Environment = var.environment
  }
}

# Task role policy for DynamoDB access (application data)
resource "aws_iam_role_policy" "task_role_dynamodb" {
  name = "${var.project_name}-${var.environment}-dynamodb-access"
  role = aws_iam_role.task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = [
          "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.project_name}-*"
        ]
      }
    ]
  })
}

# Task role policy for CloudWatch Logs
resource "aws_iam_role_policy" "task_role_logs" {
  name = "${var.project_name}-${var.environment}-logs-access"
  role = aws_iam_role.task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.project_name}-${var.environment}*:*"
        ]
      }
    ]
  })
}
