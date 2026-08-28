# 具身智能数据合成方法 · 工程案例库

> **仓库**：[github.com/wangyukai0908/embodied-data-synthesis](https://github.com/wangyukai0908/embodied-data-synthesis)  
> **完整 PPT 文稿（40 页逐页）**：[docs/presentation-source.md](docs/presentation-source.md)  
> **调研长文**：[docs/research-survey.md](docs/research-survey.md)  
> **大文件（视频 / LeRobot / 指标）**：建议放 Hugging Face Dataset，见 [docs/HF_UPLOAD.md](docs/HF_UPLOAD.md)（上传后把链接填到下方「资源地址」）

---

## 1. 项目定位

本仓库不是又一个上游模型 monorepo，而是一份**可复核的研究 / 工程案例库**：

| 本仓库是什么 | 本仓库不是什么 |
|---|---|
| 公司汇报《具身智能数据合成方法》的**内容源 + 可运行编排** | NVIDIA / Cosmos / GR00T 上游代码的完整镜像 |
| 两条已跑通链路的参数化脚本、补丁、证据边界与清单 | 权重、完整 126 视频、150G checkpoint 的 Git 托管处 |
| 讲清「合成的是轨迹契约，不是堆视频」 | 宣称策略成功率已提升或真机泛化已验证 |

**一句话主张（与最终版 PPT 一致）：**  
具身智能数据合成不是简单增加视频数量，而是围绕**视觉、状态、语言、动作、时间**五类数据契约，补齐真实数据的覆盖、监督与成本缺口，并最终通过 VLA / WAM 的下游控制效果验收。

**两条已验证工程路径：**

1. **DreamGen（无动作视频）→ IDM 伪动作 → LeRobot → GR00T 微调**  
2. **Cosmos 动作条件：真实 Bridge action → 未来视频**（不经 IDM）

---

## 2. 资源地址

| 资源 | 地址 | 状态 |
|---|---|---|
| 代码与文档 | https://github.com/wangyukai0908/embodied-data-synthesis | 已推送（`master`；`main` 合并视网络情况） |
| PPT 二进制 | 本地桌面 `具身智能数据合成方法-公司汇报-最终版.pptx` | **不进 Git**（版权 / 体积）；正文在 `docs/presentation-source.md` |
| 大文件 Dataset | `https://huggingface.co/datasets/<你的账号>/embodied-data-synthesis-artifacts` | **待你创建并上传**，清单见 `docs/HF_UPLOAD.md` |
| 上游 GR00T-Dreams | 外部 clone，revision `ec3881d...` | 见 `manifests/upstream-revisions.md` |
| 上游 cosmos-predict2 | 外部 clone，revision `661da477...` + 本仓 `patches/cosmos-predict2/` | 同上 |

### Git 里有没有视频？

**没有（有意为之）。** GitHub 不适合存：

- 126 条 DreamGen MP4（约 207 MB）
- LeRobot / IDM parquet（约十几 MB，可进 HF）
- IDM / Cosmos / GR00T 权重（数 GB～150 GB）

指标 JSON、schema、脚本已在本仓。**视频与轨迹请走 Hugging Face**，上传后把 Dataset URL 回填本节即可。

---

## 3. 最终版 PPT 目录（40 页）

与桌面《公司汇报-最终版》对齐；逐页全文见 [`docs/presentation-source.md`](docs/presentation-source.md)。

| Part | 页 | 主题 |
|---|---|---|
| — | 01–02 | 封面；回答四个问题 |
| **1** | 03–07 | 为什么需要数据合成；产业链位置；数据孤岛 |
| **2** | 08–12 | 可训练轨迹的五类契约；action / 文件结构 |
| **3** | 13–26 | 四类方法、四层级、质量门、主流路线 |
| **4** | 27–40 | DreamGen+IDM+GR00T；Bridge；证据边界；WAM；总结 |

---

## 4. PPT 正文（按页主张）

下列与汇报稿一一对应，便于只读 README 也能掌握全稿；更细的素材位与讲解备注见 `docs/presentation-source.md`。

### Part 1｜为什么需要具身智能数据合成

**Slide 03** 章节：定义、真实数据瓶颈与产业链位置。  
**Slide 04** 合成的不是视频，而是能被机器人学习的**轨迹**；五类契约；边界：视觉可看 ≠ 动作可学，数据来源 ≠ 动作监督来源。  
**Slide 05** 真实数据最可信；合成补规模与长尾；必须过动作一致性与下游质量门。  
**Slide 06** 产业链：机器人/仿真 → 采集 → 清洗 → **数据合成** → 训练 → 仿真/真机验证 → 失败回流。  
**Slide 07** GR00T「数据孤岛」：Real / Synthetic / Web·Human 分布不同层，动作监督与 schema 不天然兼容。

### Part 2｜一条可训练轨迹由什么组成

**Slide 08–09** 五类契约：视觉、状态、语言、动作、时间。  
**Slide 10** 同叫 action，机械臂 / 移动操作 / 人形 / 灵巧手含义不同；坐标系、频率、归一化必须与本体同步。  
**Slide 11** LeRobot：MP4 存观察，Parquet 存状态/动作/时间，元数据定义任务、本体、字段与统计量。  
**Slide 12**（若稿中有接口页）VLA 训练接口要读得懂统一 schema，而不是裸视频文件夹。

### Part 3｜方法谱系与评价

**Slide 13–14** 四类主方法：  
A 仿真与轨迹重组 · B 无动作视频 + IDM/latent · C 动作条件世界模型 · D WAM。  
横向评价：混合闭环、质量门。

**Slide 15｜四个数据层级**

| 层级 | 生成过程 | 动作监督 | VLA 可用性 |
|---|---|---|---|
| 只有视觉 | 文本/首帧 → 视频 | 无 | 通常不能 |
| 动作条件视频 | 动作 → 未来视频 | 外部动作 | 需验证遵循 |
| 伪动作轨迹 | 视频 → IDM/latent | 模型伪标签 | 取决于质量 |
| 完整轨迹 | 五类契约齐全 | 结构化动作 | 可进训练接口 |

**Slide 16** 仿真：画面+状态+动作一体；风险 sim2real。  
**Slide 17** MimicGen：一次示范 → 多场景回放；失败/碰撞必须筛除。  
**Slide 18** 人类视频能教任务，不能直接教关节；需 retargeting。  
**Slide 19** 无动作世界模型只生成视觉未来 → 需 IDM。  
**Slide 20** 动作条件模型：`obs + action → future obs`；动作来自真实/规划，不经 IDM。  
**Slide 21** IDM：多帧视觉 → 16-step action chunk → 写回 episode（伪标签）。  
**Slide 22** WAM vs IDM：IDM 是「未来视觉→动作」；WAM 是「当前世界表征→动作」。  
**Slide 23** 闭环：真实锚点 → 仿真扩结构 → 世界模型补视觉 → IDM/WAM → **质量门** → 训练 → 回流。  
**Slide 24** 动作监督矩阵（仿真/MimicGen/人类/无动作WM/动作条件/IDM/WAM）。  
**Slide 25｜六道质量门**：文件解码 → 视觉一致性 → 时间对齐 → 动作状态合法 → 训练加载 → **策略成功率**。  
**Slide 26** 主流是混合路线，不是单一生成模型。

### Part 4｜工程验证与边界

**Slide 27–28** 案例一链路：首帧+指令 → DreamGen 视频 → IDM → LeRobot → GR00T。  
**Slide 29** 已生成 **126** 条文本条件视频；画面可用性仍需任务/动作质量评估。  
**Slide 30** IDM 写回：预处理 → `.data` → 多帧推理 → 反归一化/滑窗 → `.data_idm`。  
**Slide 31–32** GR00T 统一接口；`.data_idm` → DataConfig → DataLoader → N1-2B；**loss ≠ 成功率**。  
**Slide 33** 126 video = 126 IDM episode，可被训练读取；**尚无任务成功率对照**。  
**Slide 34** 训练至 **20k steps**：证明可加载/可更新；**≠ 策略提升**。  
**Slide 35–36** 案例二：Bridge test/13 真实 action → Cosmos 2B → 未来视频；输入 24 帧 / 输出 13 帧 @640×480；单条样本。  
**Slide 37** 已证明链路可跑通；未证明优于真数/仿真、未证明真机收益。  
**Slide 38** WAM 为潜在消费端，须逐模型验 schema（FastWAM / LingBot-VA / Mimic-Video）。  
**Slide 39** 七点总结：轨迹契约、产业链位置、五类字段、embodiment、监督来源、混合路线、rollout 验收。  
**Slide 40** Thanks。

---

## 5. 手把手教程

### 5.0 公共准备

```bash
git clone https://github.com/wangyukai0908/embodied-data-synthesis.git
cd embodied-data-synthesis

# 建议 Linux 或 Windows Git Bash / WSL
bash scripts/qa.sh
```

通过即说明：私有路径扫描、manifest、fixture、metrics、两条 **dry-run** 正常。

上游（真跑 GPU 时再 clone）：

| 用途 | 仓库 | Revision |
|---|---|---|
| DreamGen / IDM / GR00T 脚本 | [NVIDIA GR00T-Dreams](https://github.com/NVIDIA/GR00T-Dreams) | `ec3881d44545016871997f8e17dd15f1d792e91d` |
| Cosmos 动作条件推理 | GR00T-Dreams 内 `cosmos-predict2` 或官方 cosmos-predict2 | `661da4774b0ca41d082a0ecbeb47550bcf07e03f` |

```bash
cd "$UPSTREAM_COSMOS"   # cosmos-predict2 根目录
git checkout 661da4774b0ca41d082a0ecbeb47550bcf07e03f
git apply /path/to/embodied-data-synthesis/patches/cosmos-predict2/*.patch
# 详见 patches/cosmos-predict2/APPLY.md
```

准备环境变量（自行改成你的盘符，**不要**写死他人服务器路径）：

```bash
export DATA_ROOT=...          # EVAL-175 或 HF 下载目录
export CHECKPOINT_ROOT=...    # IDM / Cosmos / GR00T 权重
export OUTPUT_ROOT=...        # 输出
export UPSTREAM_REPO=...      # GR00T-Dreams 根目录
```

---

### 教程 A｜Cosmos Bridge 动作条件（默认冒烟）

**对应 PPT**：Slide 35–36。  
**证明**：动作条件视频生成接口。  
**不证明**：数据集质量、GR1、GR00T 收益。

**A1. Dry-run（无 GPU、无下载）**

```bash
bash pipelines/cosmos_bridge/run_inference.sh \
  --dry-run \
  --input tests/fixtures/bridge_test_13
```

**A2. 真跑（需样本 + 权重）**

1. 从 HF Dataset（上传后）或自备目录准备：
   - `rgb.mp4`
   - `13.json`（Bridge annotation）
2. 准备 checkpoint：
   - `Cosmos-Predict2-2B-Sample-Action-Conditioned/model-480p-4fps.pt`
   - `Cosmos-Predict2-2B-Video2World/tokenizer/tokenizer.pth`
3. 应用本仓 2 个 patch（见上）。
4. 在上游执行 `examples/video2world_action.py`（参数见 `pipelines/cosmos_bridge/README.md` 与 `evidence/metrics/bridge_test_13.json`）。
5. 校验：

```bash
python scripts/write_bridge_metrics.py --check evidence/metrics/bridge_test_13.json
```

本仓已有一次实测指标摘要：`evidence/metrics/bridge_test_13.json`（24→13 帧，640×480，4 FPS 输出等）。

---

### 教程 B｜DreamGen → IDM → LeRobot → GR00T

**对应 PPT**：Slide 28–34。  
**证明**：视频生成数量、IDM 写回、训练加载、20k step 接口。  
**不证明**：rollout 成功率。

**B1. Dry-run**

```bash
bash pipelines/dreamgen_gr00t/run_all.sh \
  --dry-run \
  --fixture tests/fixtures/dreamgen
```

**B2. 真跑阶段（均在 `UPSTREAM_REPO` 内，由本仓 launcher 约定路径）**

| 阶段 | 你要得到的产物 | 成功判据 |
|---|---|---|
| generate | `OUTPUT_ROOT/videos/*.mp4` | 数量 = 期望 episode（案例为 126），文件非空可解码 |
| lerobot | `unified.data` | parquet episode 数一致 |
| idm | `unified.data_idm` | 含 `meta/modality.json`，episode 数一致 |
| finetune | `checkpoint-$MAX_STEPS` | 例如 20000；**仅 step 证据** |

```bash
bash pipelines/dreamgen_gr00t/run_all.sh --help
# 真跑需提供 DATA_ROOT / CHECKPOINT_ROOT / OUTPUT_ROOT / UPSTREAM_REPO
# 非空输出目录默认拒绝覆盖；需要时才加 --allow-overwrite
```

画 loss（有 `trainer_state.json` 时）：

```bash
uv run scripts/plot_gr00t_loss.py /path/to/trainer_state.json evidence/plots/gr00t_loss.png
```

---

### 教程 C｜把大文件传到 Hugging Face

见 **[docs/HF_UPLOAD.md](docs/HF_UPLOAD.md)**。推荐优先传：

1. Bridge test/13 输入输出（最小）  
2. DreamGen 126 MP4  
3. `.data_idm`  
4. `trainer_state.json`

**不要**默认把 10GB+ IDM / 19GB+ GR00T ckpt / Cosmos 权重塞进 Dataset；官方权重链到 NVIDIA HF 即可。

---

## 6. 仓库结构

```text
docs/
  presentation-source.md   # 最终版 PPT 逐页全文
  research-survey.md       # 调研与证据词汇
  HF_UPLOAD.md             # 大文件上传指南
pipelines/
  cosmos_bridge/           # 教程 A
  dreamgen_gr00t/          # 教程 B
scripts/                   # qa、扫描、metrics、loss 图
patches/cosmos-predict2/   # Bridge 推理所需 2 个最小补丁
manifests/                 # 溯源、产物、主张边界
evidence/                  # 小体积证据（metrics/schema）
tests/fixtures/            # dry-run 夹具
```

---

## 7. 证据边界（汇报时勿越界）

| 观测 | 含义 | 不等于 |
|---|---|---|
| 126 MP4 | 批量生成完成 | 任务成功 |
| IDM `.data_idm` | 伪动作已写回 | 传感器真值 |
| GR00T 20k steps | 训练接口跑到 N 步 | 策略变强 |
| Bridge test/13 | 动作条件视频接口 | 数据总体质量 / 跨本体 |
| WAM 文档 | 参考消费端 | 已端到端训通 |

详见 `manifests/claim-status.md`、`manifests/artifacts.md`。

---

## 8. License

本仓自有脚本与文档：Apache-2.0。  
上游 GR00T / Cosmos / 数据集保留各自协议，再分发前请核对。

---

## 9. 下一步（给你）

1. 在 Hugging Face 建 Dataset，按 `docs/HF_UPLOAD.md` 上传视频与 LeRobot。  
2. 把 Dataset URL 发我或自行改本 README「资源地址」表。  
3. （可选）把 GitHub 默认分支设为包含全文的 `master`，或把 `master` 合并进 `main`（若上次网络超时未完成，可再说一声我重试）。
