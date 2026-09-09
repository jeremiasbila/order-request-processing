import json
import os
import time
from datetime import datetime, timezone

import boto3
from botocore.exceptions import ClientError

TABLE_NAME = os.environ["TABLE_NAME"]
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)


def _process_record(record):
    order = json.loads(record["body"])
    order_id = order["orderId"]

    if order.get("simulateFailure"):
        raise RuntimeError("controlled failure requested for demonstration")

    now = datetime.now(timezone.utc).isoformat()
    expires_at = int(time.time()) + (30 * 24 * 60 * 60)

    try:
        table.put_item(
            Item={
                "order_id": order_id,
                "customer_id": order["customerId"],
                "status": "PROCESSED",
                "accepted_at": order.get("acceptedAt", ""),
                "processed_at": now,
                "item_count": len(order.get("items", [])),
                "expires_at": expires_at,
            },
            ConditionExpression="attribute_not_exists(order_id)",
        )
        print(json.dumps({"level": "INFO", "event": "ORDER_PROCESSED", "orderId": order_id}))
    except ClientError as exc:
        if exc.response.get("Error", {}).get("Code") == "ConditionalCheckFailedException":
            print(json.dumps({"level": "INFO", "event": "DUPLICATE_ORDER", "orderId": order_id}))
            return
        raise


def lambda_handler(event, context):
    failures = []
    for record in event.get("Records", []):
        try:
            _process_record(record)
        except Exception as exc:
            print(json.dumps({
                "level": "ERROR",
                "event": "PROCESSING_FAILED",
                "messageId": record.get("messageId"),
                "error": str(exc),
            }))
            failures.append({"itemIdentifier": record["messageId"]})
    return {"batchItemFailures": failures}
