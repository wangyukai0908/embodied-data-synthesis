# DreamGen -> IDM -> LeRobot -> GR00T

Parameterized wrapper around owned orchestration. Upstream GR00T-Dreams stays external.

## Contract

| Variable | Meaning |
|---|---|
| `DATA_ROOT` | EVAL-175 style PNG+txt inputs |
| `CHECKPOINT_ROOT` | Cosmos / IDM / GR00T checkpoints |
| `OUTPUT_ROOT` | Videos, LeRobot, IDM, finetune outputs |
| `UPSTREAM_REPO` | Checkout of GR00T-Dreams at pinned revision |
| `MAX_STEPS` | Finetune steps (20k is step-count evidence only) |

## Commands

```bash
# Default smoke (no GPU / no download)
bash pipelines/dreamgen_gr00t/run_all.sh --dry-run --fixture tests/fixtures/dreamgen

# Help
bash pipelines/dreamgen_gr00t/run_all.sh --help
```

Real stages refuse to overwrite non-empty outputs unless `--allow-overwrite`.
Real GPU execution exits with code 3 and points to upstream entrypoints until the staging host provides paths — this prevents accidental multi-GB downloads from the casebook default command.

## Claim boundary

| Observed | Means |
|---|---|
| 126 MP4 | Generation complete |
| 126 `.data_idm` episodes | IDM pseudo-actions written |
| `checkpoint-$MAX_STEPS` | Training interface reached N steps |
| Rollout success | **Not** established by this pipeline alone |
