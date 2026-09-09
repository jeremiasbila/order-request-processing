import importlib.util
import os
from pathlib import Path

os.environ.setdefault("AWS_DEFAULT_REGION", "eu-central-1")
os.environ.setdefault("AWS_ACCESS_KEY_ID", "testing")
os.environ.setdefault("AWS_SECRET_ACCESS_KEY", "testing")
os.environ.setdefault("AWS_EC2_METADATA_DISABLED", "true")
os.environ.setdefault("TABLE_NAME", "orders")
MODULE = Path(__file__).parents[1] / "src" / "consumer" / "app.py"
spec = importlib.util.spec_from_file_location("consumer_app", MODULE)
consumer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(consumer)


def test_partial_batch_failure(monkeypatch):
    def fake_process(record):
        if record["messageId"] == "bad":
            raise RuntimeError("boom")
    monkeypatch.setattr(consumer, "_process_record", fake_process)
    event = {"Records": [{"messageId": "good", "body": "{}"}, {"messageId": "bad", "body": "{}"}]}
    result = consumer.lambda_handler(event, None)
    assert result == {"batchItemFailures": [{"itemIdentifier": "bad"}]}
