#!/usr/bin/env python3
"""Write or validate Bridge metrics JSON against the casebook contract."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

REQUIRED_KEYS = (
    "sample_id",
    "input_frames",
    "output_frames",
    "resolution",
    "fps_in",
    "fps_out",
    "action_dim",
    "checkpoint_revision",
    "tokenizer_revision",
    "command",
    "claim",
)


def validate(payload: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    for key in REQUIRED_KEYS:
        if key not in payload:
            errors.append(f"missing key: {key}")
    if payload.get("claim") != "action-conditioned video generation":
        errors.append("claim must be exactly 'action-conditioned video generation'")
    not_claims = payload.get("not_claims")
    if not isinstance(not_claims, list) or "GR00T policy gain" not in not_claims:
        errors.append("not_claims must include 'GR00T policy gain'")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", type=Path, help="Validate an existing metrics JSON")
    parser.add_argument("--write-example", type=Path, help="Write example metrics JSON")
    args = parser.parse_args()
    if args.write_example:
        example = {
            "sample_id": "bridge_test_13",
            "input_frames": 24,
            "output_frames": 13,
            "resolution": "640x480",
            "fps_in": 3,
            "fps_out": 4,
            "action_dim": 7,
            "checkpoint_revision": "pending",
            "tokenizer_revision": "pending",
            "command": "examples/video2world_action.py ...",
            "hashes": {"output_video": "pending"},
            "claim": "action-conditioned video generation",
            "not_claims": ["IDM pseudo-action recovery", "GR00T policy gain", "dataset quality"],
        }
        args.write_example.parent.mkdir(parents=True, exist_ok=True)
        args.write_example.write_text(json.dumps(example, indent=2) + "\n", encoding="utf-8")
        print(f"wrote {args.write_example}")
        return 0
    if args.check:
        payload = json.loads(args.check.read_text(encoding="utf-8"))
        errors = validate(payload)
        if errors:
            print("\n".join(errors))
            return 1
        print("METRICS OK")
        return 0
    parser.print_help()
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
