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
