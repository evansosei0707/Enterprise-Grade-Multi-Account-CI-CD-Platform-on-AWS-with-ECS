#------------------------------------------------------------------------------
# DynamoDB Table - Terraform State Locking
#------------------------------------------------------------------------------

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "${var.project_name}-tfstate-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name    = "${var.project_name}-tfstate-lock"
    Purpose = "Terraform State Locking"
  }
}
