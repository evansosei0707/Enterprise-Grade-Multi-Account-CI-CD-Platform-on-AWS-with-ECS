#------------------------------------------------------------------------------
# DynamoDB Module - Application Data Table (Inventory Items)
#------------------------------------------------------------------------------

resource "aws_dynamodb_table" "inventory_items" {
  name         = "${var.project_name}-inventory-items-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.environment == "prod" ? true : false
  }

  tags = {
    Name        = "${var.project_name}-inventory-items-${var.environment}"
    Environment = var.environment
    Purpose     = "Application Data"
  }
}
