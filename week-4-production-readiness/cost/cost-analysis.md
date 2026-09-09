# Cost Analysis

The final design remains serverless but is **not purely Free-Tier-oriented** because the networking requirement introduces an SQS Interface VPC Endpoint. There is no always-on EC2 instance, NAT Gateway, load balancer, or container cluster.

## Main cost drivers

- API Gateway HTTP API: requests and Internet data transfer.
- Lambda: invocations and GB-seconds for producer/consumer execution.
- SQS: API requests and message payload size; batching reduces receive/delete overhead.
- DynamoDB PAY_PER_REQUEST: writes, storage and any reads performed during validation/operations.
- CloudWatch: log ingestion/storage, custom metric, alarms and dashboard.
- SQS Interface VPC Endpoint: endpoint-hours per Availability Zone plus data processed.
- Data transfer: usually small for this same-Region prototype but must be modeled for production volumes.

## Cost-conscious choices

- HTTP API rather than REST API because the project requires only a small HTTP surface.
- Lambda rather than always-on EC2/ECS workers for intermittent event-driven processing.
- No NAT Gateway. The private Lambda path uses service-specific endpoints instead of general Internet egress.
- DynamoDB Gateway Endpoint for private DynamoDB routing; gateway endpoints do not have the same hourly endpoint model as interface endpoints.
- SQS-managed encryption rather than a customer-managed KMS key for the prototype.
- DynamoDB PAY_PER_REQUEST to avoid idle provisioned capacity.
- CloudWatch log retention set to 14 days instead of indefinite retention.
- Consumer concurrency is bounded to protect downstream systems and reduce uncontrolled work amplification.

## VPC endpoint trade-off

The original minimal serverless architecture could leave the Lambda functions outside a customer VPC and avoid interface-endpoint cost. The revised architecture intentionally places them in private subnets because networking is part of the project requirements and to demonstrate private AWS service access. This is a conscious architecture-versus-cost trade-off, not a claim that every Lambda workload must use a VPC.

## Production cost caveat

Use AWS Pricing Calculator for the selected Region and expected order rate, average Lambda duration/memory, message size, log volume, DynamoDB usage, VPC endpoint hours/data and external data transfer. Pricing and free-tier programs change; do not hard-code a production design around historical free-tier assumptions.
