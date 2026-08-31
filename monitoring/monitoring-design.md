# Monitoring Design

## Signals

| Signal | Metric/source | Purpose |
|---|---|---|
| Queue backlog | `ApproximateNumberOfMessagesVisible` | Detect growing work backlog |
| Queue latency | `ApproximateAgeOfOldestMessage` | Detect orders waiting too long |
| In-flight work | `ApproximateNumberOfMessagesNotVisible` | Understand active processing |
| DLQ messages | DLQ `ApproximateNumberOfMessagesVisible` | Detect poison/permanent failures |
| Processing failures | Log metric filter on `PROCESSING_FAILED` | Alert on application-level record failures |
| Lambda duration/errors/throttles | Lambda metrics | Detect compute health/capacity issues |
| API 4xx/5xx | API Gateway metrics/access logs | Detect invalid clients or service failures |

## Terraform alarms

- Oldest source message age > 120 seconds for two periods.
- Visible source messages > 50 for two periods.
- Visible DLQ messages >= 1.
- Custom processor failure metric >= 1.

Thresholds are demonstration defaults, not universal production SLOs. Production thresholds should derive from acceptable order-processing latency and normal arrival rate.

## Dashboard

Terraform creates a CloudWatch dashboard showing source backlog, message age, DLQ visible messages, Lambda duration/errors, and the custom processing-failure metric.
