output "api_url" {
  description = "Base URL of the HTTP API."
  value       = aws_apigatewayv2_api.orders.api_endpoint
}

output "queue_url" {
  value = aws_sqs_queue.orders.url
}

output "dlq_url" {
  value = aws_sqs_queue.orders_dlq.url
}

output "results_table_name" {
  value = aws_dynamodb_table.order_results.name
}

output "dashboard_name" {
  value = aws_cloudwatch_dashboard.orders.dashboard_name
}

output "aws_region" {
  value = var.aws_region
}
