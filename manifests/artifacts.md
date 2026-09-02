# External artifacts

Large artifacts stay **outside Git**. Recorded sizes/hashes from staging host on **2026-08-28**. Internal absolute paths live only in gitignored `manifests/internal/inventory.md`.

| ID | Artifact | Source | Revision / tag | Bytes | SHA256 | License / access | Storage | Claim boundary |
|---|---|---|---|---|---|---|---|---|
| A1 | EVAL-175 GR1 PNG+txt inputs | permission-required / dataset card | staging 2026-08-28 | 179850140 | pending (tree) | permission-required | object store / HF | Inputs for video generation only |
| A2 | DreamGen generated videos (126 MP4) | internal-generated | staging 2026-08-28 | ~217MB | pending tree | internal-generated | HF Dataset (待上传/对账) | Generation complete ≠ task success |
| A3 | LeRobot `.data` (pre-IDM) | internal-generated | staging 2026-08-28 | 12976370 | pending (tree; 126 parquet) | internal-generated | object store | Schema shell before IDM writeback (not in HF upload by default) |
| A4 | LeRobot `.data_idm` (126 episodes) | internal-generated | staging 2026-08-28 | ~16MB | pending tree | internal-generated | HF Dataset (待上传/对账) | IDM pseudo-actions ≠ sensor GT |
| A5 | IDM_gr1 checkpoint dir | https://huggingface.co/seonghyeonye/IDM_gr1 | staging 2026-08-28 | 9962195460 | config.json `ad694c9a1feb9a0150fcbc7d513796a25cef1b6ca3715e28e0a2a7d4afde2968` | permission-required | official HF (not in casebook Dataset) | Used for writeback only |
| A6 | GR00T N1-2B base checkpoint | https://huggingface.co/nvidia/GR00T-N1-2B | pending exact file hash | pending | pending | permission-required | official HF | Base weights not redistributed |
| A7 | GR00T finetune run ≥20k steps | internal-generated | staging; `checkpoint-20000` present | 161025022821 (dir); checkpoint-20000=19033051088 | `trainer_state.json` `9310323e2be7f8c9e03e1cdf412f6b98ddce7ad5828bd010d65b7e317162579c` | internal-generated | object store | Step count / interface only; not policy gain |
| A8 | Cosmos action-conditioned `model-480p-4fps.pt` | https://huggingface.co/nvidia/Cosmos-Predict2-2B-Sample-Action-Conditioned | align cosmos-predict2 `661da477...` | 4050091611 | `7193884d61b3842e73eb0678ffa9f48258264f75f06d76c91c41ce114ae49875` | permission-required | official HF | Bridge video gen interface |
| A9 | Cosmos Video2World `tokenizer.pth` | https://huggingface.co/nvidia/Cosmos-Predict2-2B-Video2World | align cosmos-predict2 `661da477...` | 507609880 | `38071ab59bd94681c686fa51d75a1968f64e470262043be31f7a094e442fd981` | permission-required | official HF | Tokenizer only |
| A10 | Bridge test/13 rgb + annotation | Bridge dataset sample | `test/13` | 352294 (dir); rgb=336087; json=12111 | rgb `bf84fddff88ad2afdc6ca5412124f1f91ae95c0d290303adb221d79358b41037`; json `1c9ee2f7212b68ca808e79c952244c3e024c26183855d1e66116ad78395f8909` | permission-required | staged fixture / external | One-sample smoke input |
| A11 | Bridge test/13 output video + metrics | internal-generated | staging 2026-08-28 | output mp4=428784 | output `94e649b2215185c92bf8f3d63ab8bafecb232a7c948192ae603bdd2801084482`; see `evidence/metrics/bridge_test_13.json` | internal-generated | metrics in Git; video external | Action-conditioned video; not IDM/GR00T gain |

## Public-safe evidence allowed in Git

- Schemas, small JSON metrics, loss plots, selected keyframes if license permits
- Never: full 126-video sets, full parquet datasets, weight files, >100 MiB binaries

Captured: 2026-08-28
