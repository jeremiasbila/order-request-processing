# Monitoring and Operational Design

## Logs

API Gateway access logs, producer logs and consumer logs are retained in CloudWatch for 14 days in the prototype. Log events contain order IDs/message IDs for correlation but should avoid customer-sensitive payloads.

## Metrics and alarms

- SQS `ApproximateNumberOfMessagesVisible`: backlog/capacity pressure.
- SQS `ApproximateAgeOfOldestMessage`: user-impact/SLA leading indicator.
- DLQ visible messages: poison-message isolation requiring operator action.
- Lambda `Errors`, `Duration`, `Throttles`, `ConcurrentExecutions`: worker health/capacity.
- API Gateway 4xx/5xx/latency/request count: ingestion behavior.
- Application `PROCESSING_FAILED` log metric filter: business-processing failures.

Terraform creates queue-depth, message-age, DLQ and application-failure alarms plus a dashboard. In production, wire alarms to SNS/PagerDuty/Incident Manager and define severity/runbooks.

## Suggested SLOs

Prototype: no formal SLO. Industry version: define accepted-order availability, processing latency (for example 99% processed within N minutes), DLQ rate, and error-budget policy. Alarm thresholds should then be derived from service objectives rather than arbitrary static numbers.

## Runbooks

1. DLQ non-empty: inspect reason, fix consumer/data issue, replay only after validating idempotency.
2. Oldest-message alarm: inspect Lambda concurrency/throttles and downstream capacity; increase controlled concurrency only if safe.
3. API 5xx spike: inspect producer logs, Lambda/VPC endpoint health and SQS permissions.
4. DynamoDB errors: inspect service health, throttling/account limits and endpoint policy.
