#!/usr/bin/env python3
"""Validate public manifests have required provenance columns."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

REQUIRED_HEADERS = ("source", "revision", "sha256", "license", "access")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    manifests = args.root / "manifests"
    text = "\n".join(
        path.read_text(encoding="utf-8")
        for path in manifests.glob("*.md")
        if path.is_file()
    ).lower()
    missing = [h for h in REQUIRED_HEADERS if not re.search(h, text)]
    if missing:
        print(f"Missing manifest keywords: {missing}", file=sys.stderr)
        return 1
    claim = manifests / "claim-status.md"
    if not claim.is_file():
        print("missing claim-status.md", file=sys.stderr)
        return 1
    print("MANIFEST CHECK OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
