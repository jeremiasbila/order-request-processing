resource "aws_cloudwatch_log_metric_filter" "processing_failed" {
  name           = "${local.name}-processing-failed"
  log_group_name = aws_cloudwatch_log_group.consumer.name
  pattern        = "PROCESSING_FAILED"

  metric_transformation {
    name      = "ProcessingFailures"
    namespace = "QuickCart/Orders"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "dlq_not_empty" {
  alarm_name          = "${local.name}-dlq-not-empty"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.orders_dlq.name
  }
}

resource "aws_cloudwatch_metric_alarm" "oldest_message" {
  alarm_name          = "${local.name}-oldest-message"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 120
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.orders.name
  }
}

resource "aws_cloudwatch_metric_alarm" "queue_depth" {
  alarm_name          = "${local.name}-queue-depth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  threshold           = 50
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.orders.name
  }
}

resource "aws_cloudwatch_metric_alarm" "processing_failures" {
  alarm_name          = "${local.name}-processing-failures"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ProcessingFailures"
  namespace           = "QuickCart/Orders"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_dashboard" "orders" {
  dashboard_name = "${local.name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 12, height = 6,
        properties = {
          title = "SQS backlog and age", view = "timeSeries", region = var.aws_region,
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", aws_sqs_queue.orders.name],
            [".", "ApproximateAgeOfOldestMessage", ".", "."]
          ]
        }
      },
      {
        type = "metric", x = 12, y = 0, width = 12, height = 6,
        properties = {
          title = "DLQ", view = "timeSeries", region = var.aws_region,
          metrics = [["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", aws_sqs_queue.orders_dlq.name]]
        }
      },
      {
        type = "metric", x = 0, y = 6, width = 12, height = 6,
        properties = {
          title = "Consumer Lambda", view = "timeSeries", region = var.aws_region,
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.consumer.function_name],
            [".", "Errors", ".", "."]
          ]
        }
      },
      {
        type = "metric", x = 12, y = 6, width = 12, height = 6,
        properties = {
          title = "Application processing failures", view = "timeSeries", region = var.aws_region,
          metrics = [["QuickCart/Orders", "ProcessingFailures"]]
        }
      }
    ]
  })
}
