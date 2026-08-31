# IAM and Security Design

## Trust boundaries

- API Gateway may invoke only the producer Lambda through a scoped Lambda permission.
- Producer Lambda assumes its execution role and can send messages only to the main SQS queue.
- Consumer Lambda assumes its execution role and can receive/delete messages only from the main queue and write only to the results table.
- Lambda functions can write logs only to their designated CloudWatch log groups.

## Encryption

- SQS main queue and DLQ: SQS-managed server-side encryption.
- DynamoDB: encryption at rest is provided by DynamoDB; this lab uses the service default to avoid separate KMS cost/administration.
- API traffic: API Gateway endpoint uses HTTPS.

## Secrets

No AWS access key is stored in code or Terraform variables. Lambda receives temporary credentials from its IAM role.

## API authentication trade-off

The lab endpoint is unauthenticated so the queue behavior can be demonstrated with `curl`. This is intentionally not the recommended customer production posture. Production options include:

- JWT authorizer backed by Amazon Cognito or another OIDC provider.
- IAM authorization for trusted AWS callers.
- A REST API when API keys/usage plans or specific REST API features are required.

Authentication does not replace request validation, throttling, or downstream authorization checks.

## Sensitive order data

Do not place payment card data, secrets, or unnecessary PII in SQS messages or logs. Prefer identifiers that allow the processor to retrieve protected data from the system of record when necessary.
