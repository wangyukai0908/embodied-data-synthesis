#!/usr/bin/env bash
# DreamGen -> IDM -> LeRobot -> GR00T staged launcher (parameterized).
# Default: --dry-run (no network, no GPU, no large downloads).
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)

DATA_ROOT=${DATA_ROOT:-}
CHECKPOINT_ROOT=${CHECKPOINT_ROOT:-}
OUTPUT_ROOT=${OUTPUT_ROOT:-}
UPSTREAM_REPO=${UPSTREAM_REPO:-}
MAX_STEPS=${MAX_STEPS:-20000}
BATCH_SIZE=${BATCH_SIZE:-8}
SAVE_STEPS=${SAVE_STEPS:-1000}
NUM_GPUS=${NUM_GPUS:-2}
EXPECTED_EPISODES=${EXPECTED_EPISODES:-126}
DRY_RUN=0
FIXTURE=""
STAGE=all
ALLOW_OVERWRITE=0

usage() {
  cat <<'EOF'
Usage: run_all.sh [options]

Environment / options:
  --data-root PATH          EVAL-175 style inputs (or DATA_ROOT)
  --checkpoint-root PATH    Model checkpoints (or CHECKPOINT_ROOT)
  --output-root PATH        Run outputs (or OUTPUT_ROOT)
  --upstream-repo PATH      GR00T-Dreams checkout (or UPSTREAM_REPO)
  --max-steps N             GR00T finetune steps (default 20000)
  --batch-size N            Per-GPU batch size
  --num-gpus N              GPUs for generation/IDM/finetune
  --expected-episodes N     Validation count (default 126)
  --stage NAME              all|prepare|generate|lerobot|idm|finetune
  --fixture DIR             Use tests/fixtures/dreamgen style layout
  --dry-run                 Resolve paths and print plan only (default if no args)
  --allow-overwrite         Permit non-empty output dirs (dangerous)
  -h|--help                 Show help

Success predicates (real run):
  - generated MP4 count == expected episodes and files non-empty
  - LeRobot parquet episode count == expected
  - IDM output has meta/modality.json and matching episode count
  - finetune dir contains checkpoint-$MAX_STEPS

Never downloads datasets or checkpoints implicitly.
EOF
}

if [[ $# -eq 0 ]]; then
  DRY_RUN=1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --data-root) DATA_ROOT=$2; shift 2 ;;
    --checkpoint-root) CHECKPOINT_ROOT=$2; shift 2 ;;
    --output-root) OUTPUT_ROOT=$2; shift 2 ;;
    --upstream-repo) UPSTREAM_REPO=$2; shift 2 ;;
    --max-steps) MAX_STEPS=$2; shift 2 ;;
    --batch-size) BATCH_SIZE=$2; shift 2 ;;
    --num-gpus) NUM_GPUS=$2; shift 2 ;;
    --expected-episodes) EXPECTED_EPISODES=$2; shift 2 ;;
    --stage) STAGE=$2; shift 2 ;;
    --fixture) FIXTURE=$2; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --allow-overwrite) ALLOW_OVERWRITE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

if [[ -n "$FIXTURE" ]]; then
  DATA_ROOT=${DATA_ROOT:-$FIXTURE/inputs}
  OUTPUT_ROOT=${OUTPUT_ROOT:-$FIXTURE/outputs}
  CHECKPOINT_ROOT=${CHECKPOINT_ROOT:-$FIXTURE/checkpoints}
  UPSTREAM_REPO=${UPSTREAM_REPO:-$FIXTURE/upstream_stub}
  EXPECTED_EPISODES=${EXPECTED_EPISODES:-1}
fi

require_var() {
  local name=$1
  local value=$2
  if [[ -z "$value" ]]; then
    echo "Missing required path: $name" >&2
    exit 2
  fi
}

refuse_nonempty() {
  local target=$1
  if (( ALLOW_OVERWRITE )); then
    return 0
  fi
  if [[ -e "$target" ]] && find "$target" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
    echo "Refusing to overwrite non-empty path: $target" >&2
    exit 1
  fi
}

mark_done() {
  local marker=$1
  mkdir -p "$(dirname "$marker")"
  date -Is > "$marker"
}

stage_prepare() {
  echo "[prepare] DATA_ROOT=$DATA_ROOT OUTPUT_ROOT=$OUTPUT_ROOT"
  if (( DRY_RUN )); then
    echo "[prepare] dry-run OK"
    return 0
  fi
  require_var DATA_ROOT "$DATA_ROOT"
  require_var OUTPUT_ROOT "$OUTPUT_ROOT"
  test -d "$DATA_ROOT"
  mkdir -p "$OUTPUT_ROOT"/{videos,run,logs,finetune}
  mark_done "$OUTPUT_ROOT/run/.prepare_done"
}

stage_generate() {
  echo "[generate] Cosmos video2world_gr00t via UPSTREAM_REPO=$UPSTREAM_REPO"
  if (( DRY_RUN )); then
    echo "[generate] dry-run: would write videos under $OUTPUT_ROOT/videos"
    return 0
  fi
  require_var UPSTREAM_REPO "$UPSTREAM_REPO"
  require_var CHECKPOINT_ROOT "$CHECKPOINT_ROOT"
  refuse_nonempty "$OUTPUT_ROOT/videos"
  echo "Real generation must be invoked from the GR00T-Dreams cosmos-predict2 checkout." >&2
  echo "See docs/presentation-source.md Part 4 and upstream README." >&2
  exit 3
}

stage_lerobot() {
  echo "[lerobot] convert generated videos -> LeRobot dataset"
  if (( DRY_RUN )); then
    echo "[lerobot] dry-run OK"
    return 0
  fi
  refuse_nonempty "$OUTPUT_ROOT/run/unified.data"
  echo "Run IDM_dump/{split,preprocess,raw_to_lerobot} from UPSTREAM_REPO." >&2
  exit 3
}

stage_idm() {
  echo "[idm] dump_idm_actions -> unified.data_idm"
  if (( DRY_RUN )); then
    echo "[idm] dry-run OK"
    return 0
  fi
  refuse_nonempty "$OUTPUT_ROOT/run/unified.data_idm"
  echo "Run IDM_dump/dump_idm_actions.py with CHECKPOINT_ROOT/IDM checkpoint." >&2
  exit 3
}

stage_finetune() {
  echo "[finetune] gr00t_finetune.py max_steps=$MAX_STEPS gpus=$NUM_GPUS"
  if (( DRY_RUN )); then
    echo "[finetune] dry-run OK (claims 20k steps only when real log reaches MAX_STEPS)"
    return 0
  fi
  refuse_nonempty "$OUTPUT_ROOT/finetune"
  echo "Run scripts/gr00t_finetune.py from UPSTREAM_REPO against .data_idm." >&2
  exit 3
}

echo "repo_root=$REPO_ROOT dry_run=$DRY_RUN stage=$STAGE"
echo "resolved: DATA_ROOT=${DATA_ROOT:-<unset>} CHECKPOINT_ROOT=${CHECKPOINT_ROOT:-<unset>} OUTPUT_ROOT=${OUTPUT_ROOT:-<unset>} UPSTREAM_REPO=${UPSTREAM_REPO:-<unset>}"

case "$STAGE" in
  all)
    stage_prepare
    stage_generate
    stage_lerobot
    stage_idm
    stage_finetune
    ;;
  prepare) stage_prepare ;;
  generate) stage_prepare; stage_generate ;;
  lerobot) stage_lerobot ;;
  idm) stage_idm ;;
  finetune) stage_finetune ;;
  *) echo "Unknown stage: $STAGE" >&2; exit 2 ;;
esac

echo "DONE stage=$STAGE dry_run=$DRY_RUN"
