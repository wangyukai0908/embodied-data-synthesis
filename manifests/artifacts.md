# External artifacts

Large artifacts stay **outside Git**. Record them here with storage recommendation and claim boundary.

| ID | Artifact | Source | Revision / tag | Bytes | SHA256 | License / access | Storage | Claim boundary |
|---|---|---|---|---|---|---|---|---|
| A1 | EVAL-175 GR1 PNG+txt inputs | permission-required / dataset card | pending | pending | pending | permission-required | object store / HF | Inputs for video generation only |
| A2 | DreamGen generated videos (126 MP4) | internal-generated | run id pending | pending | pending | internal-generated | object store | Generation complete ≠ task success |
| A3 | LeRobot `.data` (pre-IDM) | internal-generated | pending | pending | pending | internal-generated | object store | Schema shell; actions may be placeholders |
| A4 | LeRobot `.data_idm` (126 episodes) | internal-generated | pending | pending | pending | internal-generated | object store | IDM pseudo-actions ≠ sensor GT |
| A5 | IDM_gr1 checkpoint | HF / permission-required | pending | pending | pending | permission-required | HF cache external | Used for writeback only |
| A6 | GR00T N1-2B base checkpoint | HF / permission-required | pending | pending | pending | permission-required | HF cache external | Base weights not redistributed |
| A7 | GR00T finetune run ≥20k steps | internal-generated | pending | pending (~150G class) | pending | internal-generated | object store | Step count / interface only; not policy gain |
| A8 | Cosmos Predict2 2B action-conditioned ckpt | `nvidia/Cosmos-Predict2-2B-Sample-Action-Conditioned` | align with Cosmos rev | pending | pending | permission-required | HF | Bridge video gen interface |
| A9 | Cosmos Predict2 2B Video2World tokenizer | `nvidia/Cosmos-Predict2-2B-Video2World` (`tokenizer/*`) | align with Cosmos rev | pending | pending | permission-required | HF | Tokenizer only |
| A10 | Bridge test/13 rgb + annotation | Bridge dataset sample | `test/13` | pending | pending | permission-required | staged fixture / external | One-sample smoke input |
| A11 | Bridge test/13 output video + metrics | internal-generated | pending | pending | pending | internal-generated | `evidence/metrics/` (metrics only in Git) | Action-conditioned video; not IDM/GR00T gain |

## Hashing procedure (staging host)

```bash
# Example — run where the artifact lives; paste into this table
sha256sum path/to/artifact > evidence/metrics/<id>.sha256
```

Until hashed, leave `SHA256` as `pending`. README must not invent sizes or hashes.

## Public-safe evidence allowed in Git

- Schemas, small JSON metrics, loss plots (PNG/SVG under size limit), selected keyframes if license permits
- Never: full 126-video sets, full parquet datasets, weight files, >100 MiB binaries

Captured: 2026-08-28
