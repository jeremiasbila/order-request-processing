resource "aws_dynamodb_table" "order_results" {
  name         = "${local.name}-results"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "order_id"

  attribute {
    name = "order_id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.enable_pitr
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }
}
