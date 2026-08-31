# Cost Analysis

This design has no always-on EC2 instance, NAT Gateway, load balancer, or container cluster. Most cost varies with request volume and execution/storage usage.

## Main cost drivers

- API Gateway: API requests and data transfer.
- Lambda: invocations and GB-seconds for producer/consumer execution.
- SQS: API requests; batching helps reduce per-message receive/delete overhead.
- DynamoDB on-demand: read/write request units consumed by processing/status use and stored data.
- CloudWatch: log ingestion/storage, custom metric, alarms, dashboard.
- Data transfer: usually minor for same-Region service-to-service traffic, but external transfer may cost.

## Cost-conscious choices

- HTTP API instead of REST API because advanced REST API features are not required.
- Lambda instead of always-on EC2/ECS worker for intermittent/small workloads.
- SQS-managed encryption instead of customer-managed KMS for this lab.
- DynamoDB PAY_PER_REQUEST avoids provisioned idle capacity.
- Short CloudWatch log retention (14 days) instead of indefinite retention.
- No NAT Gateway; Lambdas do not need a VPC for these public AWS service endpoints.
- Concurrency is bounded to protect downstream systems and avoid runaway work amplification.

## Production cost caveat

Use the AWS Pricing Calculator with the selected Region and expected orders/second, average Lambda duration/memory, message size, log volume, and DynamoDB usage. Pricing and free-tier eligibility can change, so do not hard-code a coursework architecture around a single historical price point.
