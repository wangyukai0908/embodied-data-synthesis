# 素材来源与使用边界

`docs/assets/` 保存主文和汇报中使用的轻量图片、流程图导出和结果关键帧。大视频、数据集、checkpoint 不放在 Git，而由 [HF_UPLOAD.md](../HF_UPLOAD.md) 和 artifact Dataset 管理。

## 文件分组

| 文件模式 | 用途 | 备注 |
|---|---|---|
| `pkg_image*.png/jpeg` | 主文中的架构图、数据样例和关键帧 | 发布前应确认来源和再分发许可 |
| `slide_*.png` | PPT 页面渲染备份 | 仅作版式参考，不是内容源 |

## 来源规则

- 上游架构图和截图应在引用页面或汇报备注中注明项目、论文或官方 README。
- 本地生成的曲线、关键帧和流程图可按实验日期、脚本和输入产物追溯。
- 未确认许可的机器人数据、论文图表和视频帧不应新增到公开仓库；优先使用自生成示意图或链接到原始来源。
- 图片不代表仓库已经完成对应模型训练；特别是 WAM 参考图片只用于接口说明。

## 已知对应关系

| 内容 | 仓库证据 |
|---|---|
| IDM / GR00T 流程 | `evidence/flowcharts/page14_idm_gr00t_pipelines/` |
| Cosmos Bridge 流程 | `evidence/flowcharts/page29_action_conditioned_bridge/` |
| IDM/WAM 方向图 | `evidence/flowcharts/muxi_flowcharts/idm_wam_direction.mmd` |
| GR00T 20k loss | `evidence/plots/gr00t_eval175_20k_loss.png` |

