# Business Requirements

1. Accept customer order requests.
2. Reliably retain accepted orders until processing can occur.
3. Decouple order intake from processing availability.
4. Absorb short traffic spikes without losing accepted requests.
5. Process asynchronously.
6. Retry transient processing failures.
7. Isolate persistent failures from normal traffic.
8. Make queue backlog visible.
9. Provide processing logs and monitoring.
10. Apply AWS security best practices.
11. Keep the solution simple and cost-conscious.
12. Remain small enough to implement and demonstrate.
13. Manage infrastructure using Terraform.

## Success criterion

A response of HTTP 202 means the producer successfully handed the order to SQS. Once that response is returned, temporary processor unavailability must not turn the accepted request into a lost request.
