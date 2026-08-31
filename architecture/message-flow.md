# Message Flow

## Successful request

1. Client sends `POST /orders` to API Gateway.
2. API Gateway invokes the producer Lambda synchronously.
3. Producer validates JSON, creates `orderId` if needed, adds an `acceptedAt` timestamp, and calls SQS `SendMessage`.
4. Only after SQS accepts the message does the producer return HTTP `202 Accepted`.
5. Lambda's SQS event-source mapping polls the queue and invokes the consumer with a batch.
6. Consumer validates each message and performs a conditional DynamoDB `PutItem`.
7. If the `order_id` already exists, the message is treated as an already-completed duplicate.
8. Successful records are omitted from `batchItemFailures`, allowing Lambda to delete them from SQS.

## Transient failure

1. Consumer reports the failed SQS record identifier.
2. The failed message is not deleted.
3. It remains invisible until the visibility timeout expires.
4. It becomes visible and is retried.
5. Other successful records from the same batch do not need to be retried.

## Permanent failure

1. A poison message fails repeatedly.
2. SQS increments its receive count.
3. After the configured maximum receives, SQS moves the message to the DLQ.
4. A CloudWatch alarm on DLQ visible messages enters ALARM state.
5. Operations inspect the DLQ message and consumer logs before deciding whether to correct and redrive it.
