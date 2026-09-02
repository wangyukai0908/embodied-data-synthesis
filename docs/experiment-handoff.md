# 实验交接：具身智能数据合成

本文是仓库的公开版实验交接，记录已完成的接口验证、产物位置和未完成的下游实验。它不包含密码、私钥、本机路径或模型权重。

## 当前结论

已形成两条可复核的工程链路：

1. DreamGen 无动作视频 → IDM 伪动作 → LeRobot → GR00T 微调。
2. Cosmos action-conditioned：Bridge 真实 action → 未来视频。

这两条链路证明接口能够运行，不证明合成数据已经提升策略成功率、鲁棒性或真机泛化。

## 证据口径

| 事实 | 可以表述为 | 不应表述为 |
|---|---|---|
| 126 个 MP4 | 批量视频生成完成 | 126 个任务都成功 |
| 126 个 `.data_idm` episode | IDM 伪动作已写回 | 真实传感器动作 |
| GR00T 20,000 steps | DataLoader、反向传播和 checkpoint 接口跑通 | 策略性能提升 |
| Bridge `test/13` 输出 | 单样本动作条件视频接口跑通 | 整体数据质量或本体迁移完成 |
| WAM 参考文档 | 可用于接口设计和验收 | 本仓已完成 WAM 端到端训练 |

## 已完成实验

### DreamGen → IDM → GR00T

- 输入：EVAL-175 GR1 首帧和语言指令。
- 输出：126 个视频、126 个 IDM episode。
- 数据：44 维 state、44 维 action，按 GR1 的双臂、双手、双腿、颈部和腰部分组。
- 训练：GR00T N1-2B，`gr1_arms_waist`，2 GPU，batch size 8/GPU，20,000 steps。
- 训练记录：`global_step=20000`，`train_loss≈0.0054622`，约 3.35 小时。
- 动作性质：IDM 伪标签，不是传感器 ground truth。

### Cosmos action-conditioned Bridge

- 样本：Bridge `test/13`。
- 输入：24 帧、640×480、3 FPS 视频和真实 7D action annotation。
- 输出：13 帧、640×480、4 FPS 视频。
- 模型：`Cosmos-Predict2-2B-Sample-Action-Conditioned`；tokenizer 为 `Cosmos-Predict2-2B-Video2World`。
- 动作不经过 IDM，来源可追溯到 Bridge annotation。
- 当前只验证单样本接口，尚未完成动作反事实、多样本统计或下游控制评估。

## 远程产物位置

容器内的数据挂载点通常映射到服务器的数据盘。公开文档只使用以下变量：

```text
$SERVER_HOME/                    代码和轻量源文件
$SERVER_DATA_ROOT/datasets/      数据集
$SERVER_DATA_ROOT/checkpoints/   模型权重
$SERVER_DATA_ROOT/outputs/       输出和日志
$SERVER_DATA_ROOT/cache/         HF/Torch 缓存
```

本项目主要产物：

```text
$SERVER_DATA_ROOT/dreamgen/datasets/EVAL-175/
$SERVER_DATA_ROOT/dreamgen/outputs/eval175_gr1_videos/
$SERVER_DATA_ROOT/dreamgen/run/eval175_gr1_unified.data
$SERVER_DATA_ROOT/dreamgen/run/eval175_gr1_unified.data_idm
$SERVER_DATA_ROOT/dreamgen/outputs/gr00t_finetune_eval175_gr1_20k/
$SERVER_DATA_ROOT/cosmos-action-bridge/inference/bridge_test_13_official.mp4
```

可公开分享的选定产物位于 Hugging Face Dataset：

<https://huggingface.co/datasets/wangyukai0908/embodied-data-synthesis-artifacts>

其中包含 126 个视频、`.data_idm` 和 Bridge 冒烟结果；GR00T checkpoint、IDM checkpoint、Cosmos 权重和完整训练目录不进入 Git 或该 Dataset。

## 复现入口

```bash
bash pipelines/cosmos_bridge/run_inference.sh --dry-run \
  --input tests/fixtures/bridge_test_13

bash pipelines/dreamgen_gr00t/run_all.sh --dry-run \
  --fixture tests/fixtures/dreamgen
```

真跑前固定上游 revision，准备数据、权重和输出目录，并避免覆盖非空目录。完整参数见 [README](../README.md) 和各 pipeline README。

## 已知问题

- 旧版 `imageio`/`av` 组合可能导致 MP4 codec 或帧形状错误；当前记录的修复是 `imageio=2.37.0`、`av=12.3.0`。
- Cosmos action-conditioned 对 action_dim、条件帧数、输出帧数和 temporal sampling 有严格约束。
- 双卡运行前检查 `CUDA_VISIBLE_DEVICES`、`torchrun --nproc_per_node` 和容器 GPU 映射，避免两个 rank 使用同一张卡。
- 大数据、checkpoint 和缓存应放在 `/mnt/data`，不要放在根分区或 `/home`。

## 尚未完成

- DreamGen 126 条视频的逐条任务成功率和物理一致性标注。
- IDM 动作的仿真/真机 replay 与真实动作对照。
- GR00T 真实、合成、混合数据的控制基线实验。
- DreamGen 轨迹接入 FastWAM、LingBot-VA 或 Mimic-Video 的端到端验证。
- Cosmos action-conditioned 的多样本统计、反事实动作测试和下游策略收益。

## 交接后的最小实验矩阵

| 组别 | 数据 | 目的 |
|---|---|---|
| A | 真实/公开 Bridge 或 GR1 数据 | 建立真实数据基线 |
| B | DreamGen 视频 + IDM 伪动作 | 测试无动作世界模型路线 |
| C | 真实 action + Cosmos 生成视频 | 测试动作条件视觉路线 |
| D | A+B 或 A+C 混合 | 检查合成数据是帮助还是污染 |

每组固定相同的相机、动作窗口、训练步数、replan 规则和 trial 数，最终报告 rollout 成功率、失败类型和泛化表现。
