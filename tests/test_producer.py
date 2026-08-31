import importlib.util
import json
import os
from pathlib import Path

os.environ.setdefault("AWS_DEFAULT_REGION", "eu-central-1")
os.environ.setdefault("AWS_ACCESS_KEY_ID", "testing")
os.environ.setdefault("AWS_SECRET_ACCESS_KEY", "testing")
os.environ.setdefault("AWS_EC2_METADATA_DISABLED", "true")
os.environ.setdefault("QUEUE_URL", "https://sqs.eu-central-1.amazonaws.com/123/orders")

MODULE = Path(__file__).parents[1] / "src" / "producer" / "app.py"
spec = importlib.util.spec_from_file_location("producer_app", MODULE)
producer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(producer)


class FakeSQS:
    def __init__(self): self.calls = []
    def send_message(self, **kwargs):
        self.calls.append(kwargs)
        return {"MessageId": "m-1"}


def test_valid_order_returns_202(monkeypatch):
    fake = FakeSQS()
    monkeypatch.setattr(producer, "sqs", fake)
    event = {"body": json.dumps({"customerId": "C1", "items": [{"sku": "A", "quantity": 1}]})}
    result = producer.lambda_handler(event, None)
    assert result["statusCode"] == 202
    assert len(fake.calls) == 1


def test_invalid_order_not_enqueued(monkeypatch):
    fake = FakeSQS()
    monkeypatch.setattr(producer, "sqs", fake)
    event = {"body": json.dumps({"customerId": "C1", "items": []})}
    result = producer.lambda_handler(event, None)
    assert result["statusCode"] == 400
    assert fake.calls == []
