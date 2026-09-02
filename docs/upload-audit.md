# 上传审计记录

盘点日期：2026-09-02。本文只记录类别、数量和存储位置约定，不包含本机绝对路径、密码或密钥。

## 结论

- GitHub 仓库已包含代码、文档、流程图、轻量指标和 loss 图；QA、私有路径扫描和 manifest 检查均通过。
- Hugging Face artifact Dataset 当前未能通过 API 对账；本次没有实际上传操作的可验证记录。README 和 manifest 中的 HF 地址仅作为目标仓库/历史约定，恢复网络并配置 token 后需重新核对。
- 服务器仍保留完整实验产物。GR00T checkpoint、IDM/Cosmos/WAM 权重、训练目录和缓存没有上传，也不应放入 GitHub；它们应通过上传脚本、官方模型地址或服务器交接路径获取。
- EVAL-175 原始输入、IDM 前 `.data`、完整 GR00T 训练目录、WAM 模型目录仍属于未公开材料。是否上传需要数据许可和接手方需求，不应默认上传。

## 服务器盘点

服务器根约定为 `$SERVER_DATA_ROOT`（通常映射到服务器数据盘）；下表是远端扫描到的当前状态。

| 位置 | 扫描结果 | 公开状态 | 处理建议 |
|---|---:|---|---|
| `$SERVER_DATA_ROOT/dreamgen/datasets/EVAL-175` | 126 PNG + 126 指令文本，约 174 MB | 未上传 | 保留远端；确认数据许可后再决定 |
| `$SERVER_DATA_ROOT/dreamgen/outputs/eval175_gr1_videos` | 126 MP4 + 126 文本，约 208 MB | 待 HF 对账/上传 | 以 HF 为分享入口，远端作为工作副本 |
| `$SERVER_DATA_ROOT/dreamgen/run/eval175_gr1_unified.data` | 126 MP4 + 126 Parquet，约 13 MB | 待上传 | 作为 IDM 前对照，必要时单独上传 |
| `$SERVER_DATA_ROOT/dreamgen/run/eval175_gr1_unified.data_idm` | 126 MP4 + 126 Parquet，约 16 MB | 待 HF 对账/上传 | 说明其中动作是 IDM 伪标签 |
| `$SERVER_DATA_ROOT/dreamgen/outputs/gr00t_finetune_eval175_gr1_20k` | 约 150 GB，含 20k 训练记录和 checkpoint | 未上传 | 不上传 checkpoint；保留 `trainer_state.json`/loss 摘要即可 |
| `$SERVER_DATA_ROOT/cosmos-action-bridge/inputs/bridge_test_13` | RGB 视频 + annotation，约 348 KB | 选定材料已登记 | 按许可保留最小样本 |
| `$SERVER_DATA_ROOT/cosmos-action-bridge/inference/materials` | 输入/输出视频、关键帧、曲线、日志，约 3.3 MB | 轻量证据已登记 | 日志只作为远端复核材料 |
| `$SERVER_DATA_ROOT/dreamgen/checkpoints`、`$SERVER_DATA_ROOT/cosmos-action-bridge/checkpoints` | 约 79 GB + 4.8 GB | 未上传 | 使用官方 HF 权重地址，不复制到 Git/HF artifact |
| `$SERVER_DATA_ROOT/models/fastwam`、`$SERVER_DATA_ROOT/models/lingbot-va*`、`$SERVER_DATA_ROOT/models/mimic-video` | WAM 模型与缓存 | 未上传 | 仅保留服务器/外部项目，不纳入本仓 artifact |

## 本地盘点

工作区仍有两类镜像：

- `01_Research/Artifacts/DreamGen-EVAL175-20260817`：约 246 MB，包含视频、Parquet、指令和日志的本地证据副本；与服务器产物存在重复，不等于已经公开上传。
- `codes/<remote-data-mirror>`：约 222 MB，是服务器轻量目录镜像，包含 126 MP4、252 Parquet 和 PNG/JSON 等；它是本地交接副本，不是 Git 仓库的一部分。
- `codes/<remote-project-mirror>`：约 2.1 GB，包含 GR00T-Dreams、Cosmos、FastWAM、LingBot-VA、Mimic-Video 等源代码镜像；这些项目应通过各自上游 revision 获取。

仓库的 `.gitignore` 已拦截视频、Parquet、权重、缓存和本地内部清单；`manifests/internal/inventory.md` 仅用于本机/服务器交接，不发布到 GitHub。

## 仍未上传但可能有价值的材料

1. EVAL-175 原始 PNG/指令：需要先确认数据集再分发许可。
2. IDM 前 `.data`：适合作为“动作写回前后”对照，但不是当前最小复现必需品。
3. 完整 Bridge 原始数据或多样本推理结果：当前只有 `test/13` 冒烟样本。
4. WAM 训练/评估输出：当前仓库只有接口说明，没有 FastWAM、LingBot-VA 或 Mimic-Video 的端到端训练证据。

## 核验限制

本次服务器扫描通过 SSH 完成。Hugging Face API 在盘点时连接超时，且未取得 token，因此无法证明目标仓库已包含这些文件；网络和凭证恢复后应执行 Dataset tree 对账，重点核对文件数量、大小和 sha256。
