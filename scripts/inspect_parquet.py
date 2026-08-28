#!/usr/bin/env python3
"""Inspect a LeRobot-style parquet episode for action column sanity (optional pyarrow)."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("parquet", type=Path, nargs="?", help="Path to episode_*.parquet")
    parser.add_argument("--fixture-check", action="store_true", help="Validate fixture layout only")
    parser.add_argument(
        "--fixture-root",
        type=Path,
        default=Path(__file__).resolve().parents[1] / "tests" / "fixtures",
    )
    args = parser.parse_args()

    if args.fixture_check or args.parquet is None:
        dreamgen = args.fixture_root / "dreamgen" / "fixture_manifest.json"
        bridge = args.fixture_root / "bridge_test_13" / "fixture_manifest.json"
        missing = [str(p) for p in (dreamgen, bridge) if not p.is_file()]
        if missing:
            print("Missing fixtures:", *missing, sep="\n", file=sys.stderr)
            return 1
        print("FIXTURE LAYOUT OK")
        return 0

    try:
        import pyarrow.parquet as pq
    except ImportError:
        print("pyarrow not installed; use --fixture-check for dry validation", file=sys.stderr)
        return 2

    table = pq.read_table(args.parquet)
    names = set(table.column_names)
    for required in ("action", "timestamp", "episode_index"):
        if required not in names:
            print(f"missing column: {required}", file=sys.stderr)
            return 1
    action = table.column("action")
    print(f"rows={table.num_rows} columns={len(names)} action_type={action.type}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
