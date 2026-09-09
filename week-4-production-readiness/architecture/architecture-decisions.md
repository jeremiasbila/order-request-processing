# Final Architecture Decisions and Trade-offs

## SQS Standard vs FIFO
Selected Standard because strict order sequencing is not a requirement. Trade-off: at-least-once delivery requires idempotency. FIFO is appropriate if per-order-group ordering and deduplication outweigh throughput/complexity considerations.

## Lambda vs ECS/Fargate/EC2
Selected Lambda for short event-driven work and minimal operations. Fargate becomes attractive for long-running processing, custom runtimes, sustained CPU or predictable always-on workloads. EC2 gives maximum control but adds patching/scaling/HA work not justified here.

## HTTP API vs REST API
Selected HTTP API for the small endpoint. REST API is justified by features such as API keys/usage plans, request transformation requirements or other features unavailable in HTTP APIs.

## DynamoDB vs RDS/Aurora
Selected DynamoDB for serverless conditional idempotency/result writes. Relational databases are better when the domain requires complex transactions, joins, relational integrity and SQL reporting.

## Private Lambda networking vs no VPC
Original minimum-cost serverless design could leave Lambda outside a customer VPC. This revision attaches both functions to private subnets because the project explicitly requires networking design and because it demonstrates private service access. Trade-off: VPC ENIs and especially SQS Interface Endpoint cost/complexity increase.

## Interface endpoints vs NAT Gateway
Selected SQS interface endpoint plus DynamoDB gateway endpoint, with no NAT. This limits network egress and avoids NAT fixed/data cost. Trade-off: interface endpoints also carry hourly/data cost and each additional AWS service may need another endpoint. If the worker must reach many Internet/SaaS destinations, NAT may be operationally simpler.

## Public subnets with no current workload
Public subnets are reserved for future ALB/NAT use. Deploying a bastion/EC2 workload merely to populate them would add unnecessary attack surface.

## Single Region vs Multi-Region
Single Region is appropriate for a four-week prototype. Trade-off: no automated regional DR. Industry evolution is documented in the DR plan.
