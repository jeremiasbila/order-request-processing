# Architecture Decisions and Trade-offs

## ADR-001: Asynchronous queue between intake and processing

**Decision:** SQS sits between producer and consumer.

**Why:** The central business requirement is that a temporary worker outage or overload must not cause an accepted order to be lost. SQS provides a durable buffer and separates intake capacity from processing capacity.

**Trade-off:** Processing is eventually consistent. The API returns acceptance, not completion. Clients that need final status require a status endpoint/event in a future iteration.

## ADR-002: SQS Standard instead of FIFO

**Decision:** Use a Standard queue.

**Why:** The requirements do not state that all orders must be processed in strict order. Standard queues suit high-throughput decoupling and permit independent worker scaling.

**Alternative:** FIFO gives ordered processing within message groups and deduplication features.

**Why not FIFO here:** FIFO adds ordering semantics the business did not request and can constrain throughput per message group. Standard's at-least-once delivery is acceptable because the consumer is idempotent.

## ADR-003: Lambda consumer instead of EC2/ECS worker

**Decision:** Use Lambda with an SQS event source mapping.

**Why:** Native queue polling, no server management, automatic scaling, pay-per-use execution, and a small operational footprint match a four-week implementation project.

**Alternatives:** ECS/Fargate or EC2 workers provide more control, long-running processes, custom runtimes, and predictable reserved capacity.

**Why not here:** They introduce task/service/cluster or instance lifecycle management that is not required for short stateless order processing.

**Limitation:** Lambda runtime duration, concurrency, ephemeral execution model, and cold starts make it unsuitable for some long-running or specialized workloads.

## ADR-004: API Gateway HTTP API + producer Lambda

**Decision:** Expose `POST /orders` using an HTTP API backed by a small Lambda producer.

**Why:** The producer is a clear architectural component that performs request validation, generates a server-side order ID, adds metadata, and only returns 202 after SQS accepts the message.

**Alternatives:** API Gateway can integrate directly with SQS, eliminating the producer Lambda. A Lambda Function URL is another simple HTTP option. API Gateway REST API offers additional mature API-management features.

**Why not direct SQS integration:** It is excellent for very thin ingestion, but this project benefits pedagogically and operationally from a distinct validation/normalization boundary. If producer logic becomes trivial and clients generate trustworthy IDs, direct API Gateway-to-SQS is a valid cost/latency optimization.

**Why HTTP API over REST API:** The project only needs a simple HTTP route; REST API features such as API keys/usage plans, extensive request transformation, and other advanced controls are not required.

## ADR-005: DynamoDB for result + idempotency

**Decision:** Write processed orders to a DynamoDB on-demand table using a conditional write.

**Why:** SQS Standard is at-least-once. A durable idempotency boundary is needed to prevent a duplicate message from producing duplicate state. DynamoDB supports atomic conditional writes and serverless scaling.

**Alternatives:** RDS/Aurora, S3, or an external order database.

**Why not here:** A relational database would add connection management and higher baseline complexity. S3 is not a natural low-latency key-based idempotency store.

**Limitation:** This simple implementation treats writing the result record as the business side effect. Real multi-system order workflows may need a stronger idempotency/state-machine design or transactional outbox pattern.

## ADR-006: SQS-managed encryption instead of customer-managed KMS key

**Decision:** Enable SQS-managed SSE.

**Why:** Provides encryption at rest without separate KMS key policy administration or KMS request charges.

**Alternative:** Customer-managed KMS key gives stronger key ownership, granular key policy, rotation/governance, and independent audit controls.

**Upgrade trigger:** Regulatory requirements, cross-team key ownership, explicit key revocation, or mandated customer-managed cryptographic controls.

## ADR-007: Bounded Lambda concurrency

**Decision:** Set event source `maximum_concurrency` to 10 initially.

**Why:** A queue can absorb a burst, but unbounded consumer scale can simply move overload to a downstream system. A concurrency cap creates backpressure while preserving accepted messages.

**Trade-off:** During a large burst, queue age increases. Alarm on `ApproximateAgeOfOldestMessage` and tune concurrency from observed processing duration and downstream capacity.

## ADR-008: No Step Functions in the first version

**Decision:** Keep processing inside one Lambda.

**Why:** The required workflow is one processing step plus retry/DLQ handling. SQS + Lambda already supplies the needed retry model.

**Upgrade trigger:** Multiple business steps, compensations, human approval, long waits, or explicit workflow state become requirements.
