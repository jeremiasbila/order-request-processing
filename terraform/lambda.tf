resource "aws_cloudwatch_log_group" "producer" {
  name              = "/aws/lambda/${local.name}-submit-order"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "consumer" {
  name              = "/aws/lambda/${local.name}-process-order"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "producer" {
  function_name    = "${local.name}-submit-order"
  role             = aws_iam_role.producer.arn
  runtime          = "python3.12"
  handler          = "app.lambda_handler"
  filename         = data.archive_file.producer.output_path
  source_code_hash = data.archive_file.producer.output_base64sha256
  timeout          = 5
  memory_size      = 128

  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.orders.url
    }
  }

  depends_on = [aws_cloudwatch_log_group.producer]
}

resource "aws_lambda_function" "consumer" {
  function_name    = "${local.name}-process-order"
  role             = aws_iam_role.consumer.arn
  runtime          = "python3.12"
  handler          = "app.lambda_handler"
  filename         = data.archive_file.consumer.output_path
  source_code_hash = data.archive_file.consumer.output_base64sha256
  timeout          = 10
  memory_size      = 128

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.order_results.name
    }
  }

  depends_on = [aws_cloudwatch_log_group.consumer]
}

resource "aws_lambda_event_source_mapping" "orders" {
  event_source_arn                   = aws_sqs_queue.orders.arn
  function_name                      = aws_lambda_function.consumer.arn
  batch_size                         = 10
  maximum_batching_window_in_seconds = 0
  function_response_types            = ["ReportBatchItemFailures"]

  scaling_config {
    maximum_concurrency = var.consumer_max_concurrency
  }

  depends_on = [aws_iam_role_policy.consumer]
}
