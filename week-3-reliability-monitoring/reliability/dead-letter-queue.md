# Dead-Letter Queue Design

The DLQ isolates messages that repeatedly fail normal processing.

## Why it exists

Without a DLQ, a poison message can repeatedly return to the source queue, consume Lambda invocations, create noisy logs, and interfere with healthy orders. The DLQ creates a bounded failure domain and an inspection point.

## Operational procedure

1. Alarm when visible DLQ messages are greater than zero.
2. Inspect message payload and correlation/order ID.
3. Inspect the consumer log stream around the failure timestamps.
4. Classify: malformed data, code defect, downstream outage, or unrecoverable business rule.
5. Fix the cause.
6. Redrive only messages that are safe to retry.
7. Confirm source queue age/depth returns to normal.
8. Record the incident and add a regression test.

Do not use the DLQ as a permanent archive. Retention is finite.
