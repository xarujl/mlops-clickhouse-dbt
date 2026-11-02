#!/usr/bin/env python3
"""Create the requested state/category result directly from the input CSV."""

import argparse
import csv
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("csv_path", type=Path, help="Input train.csv")
    parser.add_argument("--output", type=Path, default=Path("results/largest_transaction_by_state.csv"))
    args = parser.parse_args()

    largest = {}
    with args.csv_path.open(newline="", encoding="utf-8") as source:
        for row in csv.DictReader(source):
            state = row["us_state"]
            amount = float(row["amount"])
            tie_break = (row["transaction_time"], row["merch"], row["cat_id"])
            previous = largest.get(state)
            if previous is None or amount > previous[0] or (
                amount == previous[0] and tie_break < previous[1]
            ):
                largest[state] = (amount, tie_break, row)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as destination:
        writer = csv.writer(destination)
        writer.writerow(["us_state", "largest_transaction_category", "largest_transaction_amount", "transaction_time", "merch"])
        for state in sorted(largest):
            amount, _, row = largest[state]
            writer.writerow([state, row["cat_id"], row["amount"], row["transaction_time"], row["merch"]])
    print(f"Wrote {len(largest)} state rows to {args.output}")


if __name__ == "__main__":
    main()
