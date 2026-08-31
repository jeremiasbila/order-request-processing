# Assumptions and Constraints

- Short processing delay is acceptable; this is not a real-time checkout payment path.
- Strict global order sequencing is not a requirement.
- Order payloads fit within SQS message size limits; large documents/images are not placed in messages.
- The project demonstrates order processing rather than real payment capture or warehouse integration.
- The public demo API is intentionally simple. Production deployment requires authentication/authorization and abuse controls appropriate to the customer application.
- One AWS account and Region are used for the lab.
- `simulateFailure` is a test-only field and must not exist in a production order contract.
- DynamoDB represents the processing result and idempotency boundary for this demonstration.
