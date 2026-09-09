# Security Design

## Identity and least privilege

Producer role: `sqs:SendMessage` only to the main queue, CloudWatch log writes to its own group, and the EC2 ENI permissions Lambda requires for VPC attachment. Consumer role: receive/delete/get attributes on the main SQS queue, `dynamodb:PutItem` only on the result table, own log writes, and Lambda VPC ENI permissions. Runtime roles do not receive broad administrator permissions.

## Network security

Both functions run in private subnets across two AZs. There is no inbound Lambda security-group rule and no private-subnet Internet route. SQS is reached over an Interface VPC Endpoint whose SG accepts HTTPS only from the Lambda SG. DynamoDB is reached via a Gateway Endpoint.

## Data protection

SQS uses SSE-SQS. DynamoDB encrypts at rest. TLS is used in service calls. The prototype should not place payment-card data or unnecessary PII in queue messages. Production should use schema minimization/tokenization and, if governance requires it, customer-managed KMS keys with explicit key policies and rotation.

## API security

The demonstration endpoint is unauthenticated so the project can focus on queue behavior. **This is a prototype limitation.** Production must add authentication/authorization (for example a JWT authorizer), AWS WAF where Internet exposure warrants it, request-schema validation, tighter throttling, abuse detection, and organization-level logging/security controls.

## Secrets

No credentials are embedded in source. If future processing requires database/API credentials, store them in Secrets Manager or SSM Parameter Store and grant the consumer only the required secret read.

## Preventive and detective controls for industry use

Add CloudTrail organization trails, AWS Config, GuardDuty, Security Hub, IAM Access Analyzer, SCPs, code/dependency scanning, IaC scanning, signed artifacts, and separate dev/test/prod AWS accounts.
