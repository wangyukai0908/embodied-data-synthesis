#!/usr/bin/env python3
"""Scan tracked text files for private host/user path tokens."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

# Built from fragments so this file does not itself contain contiguous private tokens.
FORBIDDEN = (
    "wang" + "yukai",
    "sw" + "hpc",
    "10.6." + "157.17",
    "/mnt/" + "data/",
    "/home/" + "wang" + "yukai",
    "/data/" + "wang" + "yukai",
    "C:" + "\\Users",
    "C:" + "/Users",
)

SKIP_DIRS = {".git", "__pycache__", ".venv", "internal", "outputs", "checkpoints"}
TEXT_SUFFIXES = {".md", ".sh", ".py", ".json", ".yaml", ".yml", ".txt", ".toml", ".csv"}


def iter_files(root: Path) -> list[Path]:
    files: list[Path] = []
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        if path.suffix.lower() not in TEXT_SUFFIXES and path.name not in {".gitignore", "LICENSE"}:
            continue
        files.append(path)
    return files


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    hits: list[str] = []
    for path in iter_files(args.root):
        text = path.read_text(encoding="utf-8", errors="replace")
        for token in FORBIDDEN:
            if token in text:
                hits.append(f"{path.relative_to(args.root)}: {token}")
    if hits:
        print("PRIVATE PATH SCAN FAILED", file=sys.stderr)
        for hit in hits:
            print(hit, file=sys.stderr)
        return 1
    print(f"PRIVATE PATH SCAN OK files={len(iter_files(args.root))}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
