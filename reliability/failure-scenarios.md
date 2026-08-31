# Failure Scenarios

| Scenario | Expected behavior | Evidence |
|---|---|---|
| Processor temporarily unavailable | Messages remain in SQS and are processed when capacity returns | Queue depth/age, later success logs |
| Consumer code error | Failed record is retried after visibility timeout | `PROCESSING_FAILED` logs and receive count |
| Permanent poison order | After five receives, message moves to DLQ | DLQ visible count > 0 and alarm |
| Duplicate SQS delivery | DynamoDB conditional write rejects duplicate insert; consumer treats as already processed | `DUPLICATE_ORDER` log, one result item |
| Traffic spike | SQS buffers orders; Lambda consumes at bounded concurrency | queue depth rises then drains |
| DynamoDB throttling/service issue | Record fails and SQS retries; healthy records in batch can still complete | partial batch failure response |
| Invalid API JSON | Producer returns 400 and does not enqueue | API response and producer log |
| SQS SendMessage failure | Producer returns 503; it must not claim acceptance | API response and producer error log |
