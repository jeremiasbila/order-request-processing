# Final Presentation Outline

1. Business problem: synchronous overload and lost/failed requests.
2. Requirement: accepted orders survive processor unavailability.
3. Architecture diagram.
4. Why SQS and asynchronous processing.
5. Successful message flow.
6. Retry + visibility timeout.
7. DLQ demonstration.
8. At-least-once delivery and idempotency.
9. Monitoring dashboard/alarms.
10. IAM and encryption.
11. Scaling from 10 to 100 to 1,000 orders/second.
12. Cost drivers and cost-conscious choices.
13. Trade-offs: Standard vs FIFO; Lambda vs ECS; HTTP API vs REST API/direct integration; SSE-SQS vs KMS; no Step Functions.
14. Terraform/GitHub workflow.
15. Limitations and future improvements.
