# IAM and Security Design

## Trust boundaries

- API Gateway may invoke only the producer Lambda through a scoped Lambda permission.
- Producer Lambda assumes its execution role and can send messages only to the main SQS queue.
- Consumer Lambda assumes its execution role and can receive/delete/get queue attributes only from the main queue and write only to the result table.
- Both Lambda roles contain the EC2 network-interface permissions required for Lambda VPC attachment. These EC2 API actions require broad resource scope, but they do not grant access to application data.
- Lambda functions can write logs only to their designated CloudWatch log groups.

## Network controls

- Both Lambdas run in private application subnets across two Availability Zones.
- The Lambda security group has no inbound rules.
- The SQS Interface VPC Endpoint security group accepts TCP/443 only from the Lambda security group.
- Private route tables have no Internet default route.
- The SQS endpoint policy scopes `sqs:SendMessage` to the project queue.
- The DynamoDB Gateway Endpoint policy scopes `dynamodb:PutItem` to the project result table.

## Encryption

- SQS main queue and DLQ: SQS-managed server-side encryption.
- DynamoDB: encryption at rest is provided by DynamoDB; this prototype uses the service default rather than a separate customer-managed KMS key.
- API and AWS SDK service calls use HTTPS/TLS.

## Secrets

No AWS access key is stored in code or Terraform variables. Lambda receives temporary credentials from its IAM role. If future processing requires external API/database secrets, store them in AWS Secrets Manager or SSM Parameter Store and grant only the required read action to the relevant function.

## API authentication trade-off

The prototype endpoint is unauthenticated so the queue behavior can be demonstrated with `curl`. This is intentionally not a customer production posture. Production should introduce a JWT/OIDC authorizer or another appropriate identity mechanism, plus request validation, throttling and authorization checks. AWS WAF should be evaluated against the threat model and exposure pattern.

## Sensitive order data

Do not place payment-card data, secrets, or unnecessary PII in SQS messages or logs. Prefer opaque identifiers that allow the processor to retrieve protected data from the appropriate system of record when necessary.
