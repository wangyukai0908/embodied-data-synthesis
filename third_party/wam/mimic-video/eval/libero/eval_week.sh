#!/usr/bin/env bash
# Representative LIBERO ablation: 3 suites x 6 denoising stops x 10 trials/task.
set -euo pipefail

cd "$(dirname "$0")"
source "${MIMIC_VIDEO_ENV:-/path/to/mimic-video-env}/bin/activate"

nvidia_libs=$(find "${MIMIC_VIDEO_ENV:-/path/to/mimic-video-env}/lib/python3.10/site-packages/nvidia" -type d -name lib -print | sort | paste -sd:)
export LD_LIBRARY_PATH="${nvidia_libs}:/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
export TORCH_CUDNN_V8_API_DISABLED=1
export CUDA_VISIBLE_DEVICES=0
export SAPIEN_RENDER_CUDA_ORDINAL=0
export PYTHONPATH="$PWD/LIBERO"
export TOKENIZERS_PARALLELISM=false

checkpoint_dir="${MIMIC_VIDEO_CHECKPOINT_DIR:?Set MIMIC_VIDEO_CHECKPOINT_DIR}"
stops=(0 7 14 21 28 35)
configs=(
  "libero_goal|w2a_libero_goal_half_v2w_libero_goal_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000007020_fused_lr1.000e-04_layer20_bsz128|v2w_libero_goal_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000007020_fused.pt|w2a_libero_goal_half_v2w_libero_goal_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000007020_fused_lr1.000e-04_layer20_bsz128_iter_000050022.pt|libero_goal_half.json"
  "libero_object|w2a_libero_object_full_v2w_libero_object_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000008260_fused_lr1.000e-04_layer20_bsz128|v2w_libero_object_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000008260_fused.pt|w2a_libero_object_full_v2w_libero_object_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000008260_fused_lr1.000e-04_layer20_bsz128_iter_000050274.pt|libero_object_full.json"
  "libero_spatial|w2a_libero_spatial_full_v2w_libero_spatial_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000007540_fused_lr1.000e-04_layer20_bsz128|v2w_libero_spatial_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000007540_fused.pt|w2a_libero_spatial_full_v2w_libero_spatial_agentview_lora_rank256_lr1.778e-04_bsz32_iter_000007540_fused_lr1.000e-04_layer20_bsz128_iter_000051212.pt|libero_spatial_full.json"
)

for config in "${configs[@]}"; do
  IFS='|' read -r suite experiment video action stats <<< "$config"
  for stop in "${stops[@]}"; do
    echo "=== suite=${suite} stop=${stop} ==="
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
      --eval-rank 0 \
      --eval-world-size 1
  done
done
