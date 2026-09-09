import json
import os
import uuid
from datetime import datetime, timezone

import boto3
from botocore.exceptions import BotoCoreError, ClientError

sqs = boto3.client("sqs")
QUEUE_URL = os.environ["QUEUE_URL"]


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(body),
    }


def _validate(payload):
    if not isinstance(payload, dict):
        return "request body must be a JSON object"
    if not isinstance(payload.get("customerId"), str) or not payload["customerId"].strip():
        return "customerId is required and must be a non-empty string"
    items = payload.get("items")
    if not isinstance(items, list) or not items:
        return "items is required and must be a non-empty list"
    for index, item in enumerate(items):
        if not isinstance(item, dict):
            return f"items[{index}] must be an object"
        if not isinstance(item.get("sku"), str) or not item["sku"].strip():
            return f"items[{index}].sku is required"
        if not isinstance(item.get("quantity"), int) or item["quantity"] <= 0:
            return f"items[{index}].quantity must be a positive integer"
    return None


def lambda_handler(event, context):
    try:
        payload = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return _response(400, {"error": "invalid JSON body"})

    validation_error = _validate(payload)
    if validation_error:
        return _response(400, {"error": validation_error})

    order_id = payload.get("orderId") or str(uuid.uuid4())
    accepted_at = datetime.now(timezone.utc).isoformat()

    message = {
        "orderId": order_id,
        "customerId": payload["customerId"],
        "items": payload["items"],
        "acceptedAt": accepted_at,
        "simulateFailure": bool(payload.get("simulateFailure", False)),
    }

    try:
        result = sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(message),
            MessageAttributes={
                "orderId": {"DataType": "String", "StringValue": order_id}
            },
        )
    except (BotoCoreError, ClientError) as exc:
        print(json.dumps({"level": "ERROR", "event": "ENQUEUE_FAILED", "orderId": order_id, "error": str(exc)}))
        return _response(503, {"error": "order could not be accepted; retry later"})

    print(json.dumps({"level": "INFO", "event": "ORDER_ACCEPTED", "orderId": order_id, "sqsMessageId": result.get("MessageId")}))
    return _response(202, {"orderId": order_id, "status": "ACCEPTED", "acceptedAt": accepted_at})
