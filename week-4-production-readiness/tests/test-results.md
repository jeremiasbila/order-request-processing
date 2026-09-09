# Test Plan and Evidence Template

Run `pytest -q` locally and the end-to-end tests after deployment.

| Test | Procedure | Expected |
|---|---|---|
| Valid API order | POST valid JSON | 202 + orderId; queue receives message |
| Invalid order | POST empty items | 400; no SQS message |
| Single success | POST one valid order | Result appears in DynamoDB |
| Burst | Submit 50+ orders quickly | Queue buffers then drains |
| Processor unavailable | Disable event source mapping, submit orders, re-enable | Orders wait then process |
| Controlled poison | Submit `simulateFailure=true` | Retries then DLQ |
| Duplicate | Send same `orderId` twice | One result item; duplicate log event |
| Monitoring | Trigger poison/backlog | Relevant CloudWatch alarms/metrics change |

Capture screenshots or CLI outputs in your coursework evidence without committing account IDs, tokens, or sensitive data.
