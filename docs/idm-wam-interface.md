# IDM 与 WAM：接口方向对照

这份源稿用于汇报中解释两者在链路中的位置。二者都可能输出动作，但输入语义、训练用途和证据边界不同。

## 一句话方向

```text
IDM：已发生的多帧视觉变化 + 本体条件  ──逆动力学──>  伪 action chunk
WAM：当前视觉/世界表征 + 语言/状态   ──策略解码──>  直接 action chunk
```

## 对照表

| 维度 | IDM | WAM |
|---|---|---|
| 链路位置 | 数据生产 / 标签补齐 | 策略或动作预测 |
| 主要输入 | 多时刻视觉、embodiment 条件，必要时状态 | 当前视觉或世界表征、语言、状态、本体标签 |
| 主要输出 | 固定长度 action chunk，写回 LeRobot episode | 直接动作预测或由世界特征解码动作 |
| 学习问题 | 从观测变化反推“可能执行了什么” | 从当前观测和任务意图预测“下一步怎么做” |
| 动作真值 | 通常是模型伪标签；DreamGen 链路不是传感器真值 | 训练时依赖结构化轨迹动作；推理时输出待执行动作 |
| 对无动作视频的作用 | 可以补动作监督，但需质量门 | 不能自动把无动作视频变成可靠真值，除非另有动作标签或训练目标 |
| 进入 VLA/WAM 前的关键检查 | 反归一化、字段恢复、窗口平均、动作-视觉一致性 | 特征层、输入帧数、动作维度、时间窗口、统计量和 embodiment schema |
| 本仓证据 | S2/S3：126 个 episode 的写回和 DataLoader 读取 | S9：仅参考消费端，未验证 DreamGen 轨迹端到端训练 |

## 可直接放到 PPT 的简图

```text
            数据生产环节                         策略/控制环节

多帧视频 ──> IDM ──> 伪 action chunk ──> LeRobot / VLA 训练数据
                                           │
当前观测 + 语言 + 状态 ───────────────> WAM ──> 直接 action chunk ──> 执行
```

两条箭头的关键区别是：IDM 的动作是为数据补监督，WAM 的动作是推理时要执行的控制输出。两者不能因为都输出 `action chunk` 就视为同一个模型或同一类证据。

## 接口验收顺序

1. **Schema**：`observation`、`state`、`action`、`timestamp` 和 `episode` 字段齐全。
2. **维度**：动作维度、帧数、窗口长度和控制频率一致。
3. **数值**：归一化/反归一化正确，无 NaN、越界或突变。
4. **语义**：动作方向与视觉变化、embodiment 和坐标系一致。
5. **下游**：先离线误差，再仿真/真机 rollout，最后与真实数据基线比较。

前四步通过，只说明接口和标签可用；只有第五步的成功率、鲁棒性和泛化结果，才能支撑“数据带来控制收益”。

## Provenance

- IDM 数据管线：[`evidence/flowcharts/page14_idm_gr00t_pipelines/idm_01_data_pipeline.mmd`](../evidence/flowcharts/page14_idm_gr00t_pipelines/idm_01_data_pipeline.mmd)。
- GR00T 消费轨迹：[`evidence/flowcharts/page14_idm_gr00t_pipelines/gr00t_pipeline.mmd`](../evidence/flowcharts/page14_idm_gr00t_pipelines/gr00t_pipeline.mmd)。
- 统一证据状态：[`manifests/claim-status.md`](../manifests/claim-status.md)，尤其 S2、S3、S9。
- WAM 项目在汇报中的参考素材：`docs/assets/pkg_image30.png`–`pkg_image32.png`；图片只用于说明架构，不代表本仓已完成训练。
