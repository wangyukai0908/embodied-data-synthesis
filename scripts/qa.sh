#!/usr/bin/env bash
# Local release gates for the casebook repository.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

echo "== private path scan =="
python scripts/scan_private_paths.py --root "$ROOT"

echo "== manifest check =="
python scripts/check_manifests.py --root "$ROOT"

echo "== fixture layout =="
python scripts/inspect_parquet.py --fixture-check --fixture-root "$ROOT/tests/fixtures"

echo "== bridge metrics example =="
python scripts/write_bridge_metrics.py --check "$ROOT/evidence/metrics/bridge_test_13.example.json"

echo "== python compile =="
python -m py_compile scripts/*.py

echo "== dry-run pipelines =="
bash pipelines/cosmos_bridge/run_inference.sh --dry-run --input "$ROOT/tests/fixtures/bridge_test_13"
bash pipelines/dreamgen_gr00t/run_all.sh --dry-run --fixture "$ROOT/tests/fixtures/dreamgen"

echo "== large file gate (tracked tree, soft) =="
python - <<'PY'
from pathlib import Path
root = Path('.')
limit = 100 * 1024 * 1024
bad = []
for path in root.rglob('*'):
    if not path.is_file():
        continue
    if '.git' in path.parts or 'internal' in path.parts:
        continue
    if path.stat().st_size > limit:
        bad.append((path, path.stat().st_size))
if bad:
    raise SystemExit(bad)
print('LARGE FILE GATE OK')
PY

echo "ALL QA GATES PASSED"
