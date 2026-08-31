# Technical Requirements

## Functional

- `POST /orders` accepts JSON order requests.
- Producer validates required fields and assigns an order ID when absent.
- Producer writes accepted order messages to SQS.
- Consumer receives SQS messages through a Lambda event source mapping.
- Consumer writes a processed result to DynamoDB.
- Consumer safely tolerates duplicate deliveries.
- Controlled failure flag supports repeatable retry/DLQ demonstrations.
- Messages exceeding the receive threshold are isolated in a DLQ.

## Non-functional

- Managed/serverless AWS services only for the core implementation.
- Multi-AZ durability is delegated to managed services.
- No application credentials stored in source code.
- Least-privilege IAM between components.
- Encryption at rest for queued order data.
- CloudWatch logs and alarms for backlog, age, processor failures, and DLQ messages.
- Infrastructure reproducible by Terraform.
- Safe burst handling through queue buffering and bounded consumer concurrency.
