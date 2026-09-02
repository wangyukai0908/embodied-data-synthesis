#!/usr/bin/env bash
set -euo pipefail

# Resumable uploader for the remote experiment host. Run this script on the
# host that can read SERVER_DATA_ROOT. Third-party weights and caches are
# explicit opt-ins because their redistribution rights and size vary.

PYTHON_BIN="${PYTHON_BIN:-python}"
DATA_ROOT="${SERVER_DATA_ROOT:?Set SERVER_DATA_ROOT to the remote data root}"
DATASET_REPO="${HF_DATASET_REPO:-wangyukai0908/embodied-data-synthesis-artifacts}"
MODEL_REPO="${HF_MODEL_REPO:-wangyukai0908/embodied-data-synthesis-checkpoints}"

if [[ -z "${HF_TOKEN:-}" ]]; then
  echo "HF_TOKEN is not set. Authenticate with hf auth login or export HF_TOKEN." >&2
  exit 2
fi

if [[ "${HF_ALLOW_THIRD_PARTY_WEIGHTS:-0}" != "1" ]]; then
  echo "Refusing third-party model upload. Set HF_ALLOW_THIRD_PARTY_WEIGHTS=1 only after checking licenses." >&2
  exit 3
fi

export HF_TOKEN

upload() {
  local src="$1" dst="$2" repo="$3" repo_type="$4"
  [[ -e "$src" ]] || { echo "Missing: $src" >&2; exit 4; }
  echo "Uploading $src -> $repo:$dst"
  "$PYTHON_BIN" - "$src" "$dst" "$repo" "$repo_type" <<'PY'
import os, sys
from huggingface_hub import HfApi

src, dst, repo, repo_type = sys.argv[1:]
api = HfApi(token=os.environ["HF_TOKEN"])
api.create_repo(repo_id=repo, repo_type=repo_type, private=True, exist_ok=True)
if os.path.isdir(src):
    # Keep generated logs and transient caches out unless explicitly requested.
    ignore = [] if os.environ.get("HF_UPLOAD_CACHES") == "1" else [
        "**/.cache/**", "**/cache/**", "**/caches/**", "**/logs/**",
        "**/outputs/**", "**/runs/**", "**/wandb/**", "**/*.log",
    ]
    api.upload_folder(folder_path=src, path_in_repo=dst, repo_id=repo,
                      repo_type=repo_type, ignore_patterns=ignore,
                      commit_message=f"Upload {dst}")
else:
    api.upload_file(path_or_fileobj=src, path_in_repo=dst, repo_id=repo,
                    repo_type=repo_type, commit_message=f"Upload {dst}")
PY
}

# User-generated data and the IDM-before comparison are Dataset artifacts.
upload "$DATA_ROOT/dreamgen/datasets/EVAL-175" \
  "dreamgen_eval175_gr1/input" "$DATASET_REPO" dataset
upload "$DATA_ROOT/dreamgen/run/eval175_gr1_unified.data" \
  "dreamgen_eval175_gr1/lerobot_data_pre_idm" "$DATASET_REPO" dataset

# The complete 20k run and weights are kept in a private Model repository.
upload "$DATA_ROOT/dreamgen/outputs/gr00t_finetune_eval175_gr1_20k" \
  "gr00t_finetune_eval175_gr1_20k" "$MODEL_REPO" model
upload "$DATA_ROOT/dreamgen/checkpoints" \
  "dreamgen_checkpoints" "$MODEL_REPO" model
upload "$DATA_ROOT/cosmos-action-bridge/checkpoints" \
  "cosmos_action_bridge_checkpoints" "$MODEL_REPO" model
upload "$DATA_ROOT/models/fastwam" "fastwam" "$MODEL_REPO" model
upload "$DATA_ROOT/models/lingbot-va-posttrain-libero-long" \
  "lingbot-va-posttrain-libero-long" "$MODEL_REPO" model
upload "$DATA_ROOT/models/mimic-video" "mimic-video" "$MODEL_REPO" model

if [[ "${HF_UPLOAD_CACHES:-0}" == "1" ]]; then
  echo "Upload complete, including cache files (HF_UPLOAD_CACHES=1)."
else
  echo "Upload complete. Transient caches/logs/outputs were excluded; set HF_UPLOAD_CACHES=1 to include them."
fi
