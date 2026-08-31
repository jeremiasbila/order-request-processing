# Retry Strategy

## Configuration

- Lambda processor timeout: 10 seconds.
- SQS visibility timeout: 60 seconds.
- Event source batch size: 10.
- Partial batch response: enabled (`ReportBatchItemFailures`).
- DLQ redrive `maxReceiveCount`: 5.
- Main queue retention: 4 days.
- DLQ retention: 14 days.

## Rationale

A failed record becomes visible again after the visibility timeout and can be retried. The visibility timeout is intentionally longer than the processor timeout to prevent another worker from immediately receiving the same in-flight message. Five receive attempts give transient errors multiple recovery opportunities while ensuring poison messages eventually stop consuming normal processing capacity.

Partial batch responses are important when batch size is greater than one: if one record fails, successful records are not intentionally returned to the queue with it.

## Backoff

Lambda's managed SQS integration applies retry/backoff behavior. The application does not implement a tight client-side retry loop inside the processor, because doing so would consume Lambda duration and can amplify a downstream outage.

## Redrive

Do not automatically redrive DLQ messages without first fixing the root cause. Redrive after validating that the failure is transient or corrected, and monitor the source queue and processor error metrics during the redrive.
