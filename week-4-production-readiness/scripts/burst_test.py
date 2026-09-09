#!/usr/bin/env python3
import argparse
import concurrent.futures
import json
import urllib.request


def submit(api_url, i, fail=False):
    body = json.dumps({
        "customerId": f"BURST-{i}",
        "items": [{"sku": "LOAD-TEST", "quantity": 1}],
        "simulateFailure": fail,
    }).encode()
    req = urllib.request.Request(f"{api_url.rstrip('/')}/orders", data=body, headers={"content-type": "application/json"}, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            return i, r.status, r.read().decode()
    except Exception as exc:
        return i, 0, str(exc)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("api_url")
    parser.add_argument("--count", type=int, default=50)
    parser.add_argument("--workers", type=int, default=10)
    args = parser.parse_args()
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as pool:
        results = list(pool.map(lambda i: submit(args.api_url, i), range(args.count)))
    ok = sum(1 for _, status, _ in results if status == 202)
    print(f"accepted={ok}/{args.count}")
    for result in results:
        if result[1] != 202:
            print(result)

if __name__ == "__main__":
    main()
