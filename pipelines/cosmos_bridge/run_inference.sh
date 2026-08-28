#!/usr/bin/env bash
# Cosmos action-conditioned Bridge inference (minimal one-sample launcher).
# Default: --dry-run. Checkpoint download requires explicit --allow-download.
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)

INPUT_DIR=""
OUTPUT_DIR=""
CHECKPOINT_ROOT=""
UPSTREAM_REPO=""
CONTAINER=""
DRY_RUN=0
ALLOW_DOWNLOAD=0
NUM_GPUS=${NUM_GPUS:-2}
SAMPLE_ID=${SAMPLE_ID:-bridge_test_13}

usage() {
  cat <<'EOF'
Usage: run_inference.sh [options]

  --input DIR               Directory with rgb.mp4 + annotation JSON
  --output DIR              Output directory for video + metrics.json
  --checkpoint-root PATH    Cosmos checkpoints root
  --upstream-repo PATH      cosmos-predict2 checkout (pinned revision)
  --container NAME          Optional docker container (empty = host python)
  --sample-id ID            Sample id for metrics (default bridge_test_13)
  --num-gpus N              torchrun nproc (default 2)
  --dry-run                 Resolve paths only; no network/GPU
  --allow-download          Permit HF snapshot_download for checkpoints
  -h|--help

Default smoke:
  bash pipelines/cosmos_bridge/run_inference.sh --dry-run --input tests/fixtures/bridge_test_13

This route is action-conditioned video generation using real Bridge annotations.
It is not IDM pseudo-action recovery and not a GR00T policy gain claim.
EOF
}

if [[ $# -eq 0 ]]; then
  DRY_RUN=1
  INPUT_DIR="$REPO_ROOT/tests/fixtures/bridge_test_13"
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input) INPUT_DIR=$2; shift 2 ;;
    --output) OUTPUT_DIR=$2; shift 2 ;;
    --checkpoint-root) CHECKPOINT_ROOT=$2; shift 2 ;;
    --upstream-repo) UPSTREAM_REPO=$2; shift 2 ;;
    --container) CONTAINER=$2; shift 2 ;;
    --sample-id) SAMPLE_ID=$2; shift 2 ;;
    --num-gpus) NUM_GPUS=$2; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --allow-download) ALLOW_DOWNLOAD=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

INPUT_DIR=${INPUT_DIR:-$REPO_ROOT/tests/fixtures/bridge_test_13}
OUTPUT_DIR=${OUTPUT_DIR:-$INPUT_DIR/outputs}

VIDEO="$INPUT_DIR/rgb.mp4"
ANNOTATION=$(find "$INPUT_DIR" -maxdepth 1 -type f -name '*.json' ! -name 'metrics.json' | head -n 1 || true)

echo "repo_root=$REPO_ROOT dry_run=$DRY_RUN sample_id=$SAMPLE_ID"
echo "input=$INPUT_DIR output=$OUTPUT_DIR"
echo "video=$VIDEO annotation=${ANNOTATION:-<missing>}"

if [[ ! -d "$INPUT_DIR" ]]; then
  echo "Missing input dir: $INPUT_DIR" >&2
  exit 2
fi

if (( DRY_RUN )); then
  if [[ ! -f "$INPUT_DIR/fixture_manifest.json" && ! -f "$VIDEO" ]]; then
    echo "Fixture incomplete: need fixture_manifest.json or rgb.mp4" >&2
    exit 2
  fi
  mkdir -p "$OUTPUT_DIR"
  cat > "$OUTPUT_DIR/metrics.dry-run.json" <<EOF
{
  "sample_id": "$SAMPLE_ID",
  "mode": "dry-run",
  "input_dir": "$INPUT_DIR",
  "claim": "action-conditioned video generation interface only",
  "not_claims": ["IDM pseudo-action recovery", "GR00T policy gain", "dataset quality"]
}
EOF
  echo "dry-run OK -> $OUTPUT_DIR/metrics.dry-run.json"
  exit 0
fi

if [[ ! -f "$VIDEO" || -z "$ANNOTATION" || ! -f "$ANNOTATION" ]]; then
  echo "Missing inference input. This launcher does not download the Bridge archive." >&2
  echo "Required: $VIDEO and a *.json annotation beside it." >&2
  exit 2
fi

if [[ -z "$UPSTREAM_REPO" || -z "$CHECKPOINT_ROOT" ]]; then
  echo "Real run requires --upstream-repo and --checkpoint-root" >&2
  exit 2
fi

CKPT="$CHECKPOINT_ROOT/nvidia/Cosmos-Predict2-2B-Sample-Action-Conditioned/model-480p-4fps.pt"
TOK="$CHECKPOINT_ROOT/nvidia/Cosmos-Predict2-2B-Video2World/tokenizer/tokenizer.pth"

if [[ ! -s "$CKPT" || ! -s "$TOK" ]]; then
  if (( ALLOW_DOWNLOAD )); then
    echo "Checkpoints missing; --allow-download set but download must be performed with your HF tooling against CHECKPOINT_ROOT." >&2
    echo "Refusing to embed host/container-specific download commands." >&2
    exit 3
  fi
  echo "Missing checkpoints. Re-run with staged files or --allow-download after configuring HF access." >&2
  exit 2
fi

mkdir -p "$OUTPUT_DIR"
OUT_VIDEO="$OUTPUT_DIR/${SAMPLE_ID}_official.mp4"

echo "Invoke upstream examples/video2world_action.py from $UPSTREAM_REPO with:"
echo "  --input_video $VIDEO"
echo "  --input_annotation $ANNOTATION"
echo "  --save_path $OUT_VIDEO"
echo "  --dit_path $CKPT"
echo "Container override: ${CONTAINER:-<host>}"
echo "After success, write evidence/metrics via scripts/write_bridge_metrics.py"

# Soft gate: do not auto-exec docker with private names
exit 3
