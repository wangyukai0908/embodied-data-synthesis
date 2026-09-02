#!/usr/bin/env bash
# Extended LIBERO evaluation: 3 suites x 12 denoising stops x 10 trials/task.
# Each run is split across GPU 0 and GPU 1 with two evaluation ranks.
set -euo pipefail

cd "$(dirname "$0")"
source "${MIMIC_VIDEO_ENV:-/path/to/mimic-video-env}/bin/activate"

nvidia_libs=$(find "${MIMIC_VIDEO_ENV:-/path/to/mimic-video-env}/lib/python3.10/site-packages/nvidia" -type d -name lib -print | sort | paste -sd:)
export LD_LIBRARY_PATH="${nvidia_libs}:/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
export TORCH_CUDNN_V8_API_DISABLED=1
export PYTHONPATH="$PWD/LIBERO"
export TOKENIZERS_PARALLELISM=false

checkpoint_dir="${MIMIC_VIDEO_CHECKPOINT_DIR:?Set MIMIC_VIDEO_CHECKPOINT_DIR}"
log_root="${MIMIC_VIDEO_LOG_ROOT:-./logs/libero_week_2gpu}"
mkdir -p "$log_root"

# Preserve the original six points and add intermediate points around them.
stops=(0 3 7 10 14 17 21 24 28 31 33 35)
configs=(
  "libero_goal|w2a_libero_goal_half_v2w_libero_goal_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000007020_fused_lr1.000e-04_layer20_bsz128|v2w_libero_goal_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000007020_fused.pt|w2a_libero_goal_half_v2w_libero_goal_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000007020_fused_lr1.000e-04_layer20_bsz128_iter_000050022.pt|libero_goal_half.json"
  "libero_object|w2a_libero_object_full_v2w_libero_object_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000008260_fused_lr1.000e-04_layer20_bsz128|v2w_libero_object_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000008260_fused.pt|w2a_libero_object_full_v2w_libero_object_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000008260_fused_lr1.000e-04_layer20_bsz128_iter_000050274.pt|libero_object_full.json"
  "libero_spatial|w2a_libero_spatial_full_v2w_libero_spatial_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000007540_fused_lr1.000e-04_layer20_bsz128|v2w_libero_spatial_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000007540_fused.pt|w2a_libero_spatial_full_v2w_libero_spatial_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000007540_fused_lr1.000e-04_layer20_bsz128_iter_000051212.pt|libero_spatial_full.json"
)

run_rank() {
  local gpu="$1"
  local rank="$2"
  local suite="$3"
  local experiment="$4"
  local video="$5"
  local action="$6"
  local stats="$7"
  local stop="$8"
  local log_file="$log_root/${suite}_stop${stop}_rank${rank}.log"

  (
    export CUDA_VISIBLE_DEVICES="$gpu"
    export SAPIEN_RENDER_CUDA_ORDINAL=0
    echo "=== GPU=${gpu} rank=${rank}/2 suite=${suite} stop=${stop} ==="
    python run.py \
      --vam-experiment-name "$experiment" \
      --vam-video-model-path "$checkpoint_dir/video_backbone/$video" \
      --vam-action-model-path "$checkpoint_dir/action_decoder/$action" \
      --vam-dataset-statistics-path "$checkpoint_dir/dataset_statistics/$stats" \
      --vam-img-horizon 5 \
      --vam-lowdim-horizon 1 \
      --vam-stop-video-denoising-step "$stop" \
      --vam-num-execute-actions 5 \
      --task-suite-name "$suite" \
      --num-trials-per-task 10 \
      --eval-rank "$rank" \
      --eval-world-size 2
  ) >"$log_file" 2>&1 &
  RUN_PID=$!
}

for config in "${configs[@]}"; do
  IFS='|' read -r suite experiment video action stats <<< "$config"
  for stop in "${stops[@]}"; do
    echo "=== starting suite=${suite} stop=${stop} on GPU 0/1 ==="
    run_rank 0 0 "$suite" "$experiment" "$video" "$action" "$stats" "$stop"
    pid0=$RUN_PID
    run_rank 1 1 "$suite" "$experiment" "$video" "$action" "$stats" "$stop"
    pid1=$RUN_PID

    status=0
    wait "$pid0" || status=1
    wait "$pid1" || status=1
    if [[ "$status" -ne 0 ]]; then
      echo "Evaluation failed: suite=${suite} stop=${stop}" >&2
      exit "$status"
    fi
  done
done

echo "Extended two-GPU LIBERO evaluation completed."
