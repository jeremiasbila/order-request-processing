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


output "vpc_id" { value = aws_vpc.main.id }
output "private_subnet_ids" { value = [aws_subnet.private_a.id, aws_subnet.private_b.id] }
output "public_subnet_ids" { value = [aws_subnet.public_a.id, aws_subnet.public_b.id] }
output "network_summary" {
  value = {
    region             = var.aws_region
    availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
    vpc_cidr           = var.vpc_cidr
    public_subnets     = [var.public_subnet_a_cidr, var.public_subnet_b_cidr]
    private_subnets    = [var.private_subnet_a_cidr, var.private_subnet_b_cidr]
    nat_gateway        = "not deployed in prototype"
    private_endpoints  = ["SQS interface endpoint", "DynamoDB gateway endpoint"]
  }
}
