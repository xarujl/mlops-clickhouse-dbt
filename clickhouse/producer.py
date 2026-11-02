#!/usr/bin/env python3
"""Publish a CSV file to Kafka as CSVWithNames records."""

from __future__ import annotations

import argparse
import csv
import json
import time
from pathlib import Path

from kafka import KafkaProducer
from kafka.errors import NoBrokersAvailable


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("csv_path", type=Path, help="Path to train.csv")
    parser.add_argument("--bootstrap-servers", default="localhost:9092")
    parser.add_argument("--topic", default="transactions")
    parser.add_argument("--batch-size", type=int, default=5000)
    parser.add_argument("--retries", type=int, default=30)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if not args.csv_path.is_file():
        raise SystemExit(f"CSV file does not exist: {args.csv_path}")

    producer = None
    for attempt in range(args.retries):
        try:
            producer = KafkaProducer(
                bootstrap_servers=args.bootstrap_servers,
                acks="all",
                retries=5,
                max_in_flight_requests_per_connection=1,
                value_serializer=lambda value: json.dumps(value, ensure_ascii=False).encode("utf-8"),
            )
            break
        except NoBrokersAvailable:
            if attempt + 1 == args.retries:
                raise
            time.sleep(2)

    assert producer is not None
    sent = 0
    with args.csv_path.open("r", newline="", encoding="utf-8") as source:
        reader = csv.DictReader(source)
        if not reader.fieldnames:
            raise SystemExit("CSV has no header")
        for row in reader:
            producer.send(args.topic, row)
            sent += 1
            if sent % args.batch_size == 0:
                producer.flush()
                print(f"Published {sent:,} rows")

    producer.flush()
    producer.close()
    print(f"Done: published {sent:,} data rows to topic '{args.topic}'.")


if __name__ == "__main__":
    main()
