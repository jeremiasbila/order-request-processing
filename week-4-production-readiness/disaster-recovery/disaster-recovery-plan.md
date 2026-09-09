# Disaster Recovery Plan

## Prototype recovery posture

The prototype is **Multi-AZ within one AWS Region**, not Multi-Region. SQS, API Gateway, Lambda, DynamoDB and CloudWatch are regional managed services. Two private subnets and two SQS endpoint ENIs reduce dependence on one AZ, but a full regional outage remains outside prototype scope.

### Recovery objectives

For the prototype, use indicative rather than contractual targets:
- AZ impairment: RTO minutes; RPO 0 for messages already durably accepted by regional SQS, subject to AWS service guarantees.
- Accidental DynamoDB item/table loss: without PITR enabled, recovery depends on external exports/backups; this is explicitly a lab limitation.
- Regional failure: no automated recovery; redeploy to a second Region from Terraform and restore/reconstruct data.

## Backup and restore

Production setting: enable DynamoDB Point-in-Time Recovery and scheduled/on-demand backups. Terraform exposes `enable_pitr`; default is false to keep the prototype explicit about its cost/scope decision. Preserve Terraform state in a protected remote backend and retain immutable deployment artifacts in a versioned repository/artifact store.

## DLQ recovery

A DLQ is not a backup. It is a failure-isolation mechanism. Operators should investigate failed payloads, deploy/verify a fix, and redrive messages deliberately. Idempotency allows safe reprocessing of already-completed order IDs.

## Regional DR evolution

For a mature system:
1. Deploy an equivalent stack in a second Region.
2. Use DynamoDB Global Tables for replicated order state if the business requires low RPO across Regions.
3. Choose SQS strategy carefully: SQS queues are regional and do not natively replicate messages cross-Region; implement application/event replication or a recoverable upstream event log if near-zero-RPO queued work is required.
4. Front APIs with Route 53/Global Accelerator/CloudFront depending protocol and routing requirements.
5. Keep deployment artifacts and Terraform modules Region-neutral.
6. Exercise DR through scheduled game days rather than treating the plan as documentation only.

## Failure modes

| Failure | Prototype behavior | Industry enhancement |
|---|---|---|
| One AZ impaired | Lambda has subnet placement and SQS endpoint in second AZ | validate service quotas and failover through game day |
| Consumer bug | messages retry then DLQ | deployment rollback/canary, automated incident response |
| DynamoDB table deletion | manual recovery only unless backup enabled | PITR + protected deletion + backup policy |
| Region outage | unavailable until Region/service recovery | warm standby/active-active second Region |
| Terraform state loss | local state is a lab risk | S3 remote state + locking + versioning + restricted access |
