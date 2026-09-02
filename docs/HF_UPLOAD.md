# Hugging Face 大文件上传建议

GitHub 只放代码与文档；下列产物请放到 Hugging Face Dataset（或 Model）仓库。

建议 Dataset 名：`wangyukai0908/embodied-data-synthesis-artifacts`（可改）

## 建议上传清单

| 优先级 | 内容 | 约大小 | 对应 manifest | 说明 |
|---|---|---|---|---|
| P0 | Bridge test/13 输入+输出视频+keyframes | ~1–5 MB | A10, A11 | 最小可复现证据 |
| P0 | DreamGen 126×MP4 | ~207 MB | A2 | 生成完成证据，≠任务成功 |
| P0 | LeRobot `.data_idm`（126 episode） | ~15 MB | A4 | IDM 伪动作轨迹 |
| P1 | LeRobot `.data`（IDM 前） | ~12 MB | A3 | 对照用 |
| P1 | EVAL-175 输入 PNG+txt | ~172 MB | A1 | 若许可允许再传 |
| P2 | `trainer_state.json` + loss 曲线 | 小 | A7 | 20k 步训练证据 |
| 不要默认传 | IDM 权重 (~10 GB)、GR00T ckpt (~19–150 GB)、Cosmos 权重 (~4.5 GB) | 很大 | A5–A9 | 指向官方 HF；自训权重仅在需要时另开 Model 仓 |

## 推荐目录结构

```text
embodied-data-synthesis-artifacts/
  README.md                 # 证据边界 + 许可
  bridge_test_13/
    rgb.mp4
    13.json
    bridge_test_13_official.mp4
    keyframes/
  dreamgen_eval175_gr1/
    videos/*.mp4            # 126
    lerobot_data_idm/       # 完整 LeRobot 目录
    lerobot_data/           # optional
  gr00t_finetune_20k/
    trainer_state.json
    loss.png                # optional
```

## 上传命令示例

```bash
# 需先: pip install -U huggingface_hub && huggingface-cli login
huggingface-cli upload wangyukai0908/embodied-data-synthesis-artifacts \
  /path/to/bridge_test_13 \
  bridge_test_13 \
  --repo-type dataset

huggingface-cli upload wangyukai0908/embodied-data-synthesis-artifacts \
  /path/to/eval175_gr1_videos \
  dreamgen_eval175_gr1/videos \
  --repo-type dataset
```

上传后把 Dataset URL 填回本仓库根 `README.md` 的「资源地址」一节，并更新 `manifests/artifacts.md` 的 Source 列。

## 本次远端批量上传

用户指定的 EVAL-175 原始输入、IDM 前 `.data` 和 GR00T 20k 完整训练目录已纳入
`scripts/upload_remote_artifacts.sh`。前两项进入 Dataset；150GB 训练目录进入单独的
私有 Model 仓库。脚本使用 `HfApi.upload_folder`，可重复运行并在中断后继续。

```bash
export SERVER_DATA_ROOT=/path/to/server-data
export HF_TOKEN=hf_...
export HF_DATASET_REPO=wangyukai0908/embodied-data-synthesis-artifacts
export HF_MODEL_REPO=wangyukai0908/embodied-data-synthesis-checkpoints
bash scripts/upload_remote_artifacts.sh
```

脚本还支持上传 IDM、Cosmos、FastWAM、LingBot-VA 和 Mimic-Video 权重，但这部分默认拒绝，
必须在确认各上游许可证和再分发权限后显式设置
`HF_ALLOW_THIRD_PARTY_WEIGHTS=1`。模型目录中的日志、outputs、runs 和常见缓存目录默认排除；
如确实需要把缓存一并归档，再设置 `HF_UPLOAD_CACHES=1`。缓存通常包含重复 blob、临时文件和
环境状态，不是可复现模型发布物，建议只在内部私有仓库使用该开关。

上传器会自动区分目录和单文件（例如某些 `.data` 产物），可安全重复运行；中断后再次执行会
复用 Hugging Face 已存在的文件。
