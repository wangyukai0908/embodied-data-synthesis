# Cosmos Predict2 minimal patches

**Upstream revision:** `661da4774b0ca41d082a0ecbeb47550bcf07e03f`  
**Extracted:** 2026-08-28 from dirty worktree (local + remote match)

## Files

| Patch | File | Why required |
|---|---|---|
| `0001-video2world_action-pipeline.patch` | `cosmos_predict2/pipelines/video2world_action.py` | Uncomment/use `num_video_frames` and repeat the first RGB frame across the model temporal window so action-conditioned inference matches the 13-frame training window |
| `0002-video2world_action-example.patch` | `examples/video2world_action.py` | Honor `--disable_prompt_refiner` when constructing the pipeline |

## Apply

```bash
cd "$UPSTREAM_REPO"   # cosmos-predict2 checkout
git checkout 661da4774b0ca41d082a0ecbeb47550bcf07e03f
git apply /path/to/casebook/patches/cosmos-predict2/0001-video2world_action-pipeline.patch
git apply /path/to/casebook/patches/cosmos-predict2/0002-video2world_action-example.patch
```

## Check

```bash
git -C "$UPSTREAM_REPO" apply --check \
  /path/to/casebook/patches/cosmos-predict2/0001-video2world_action-pipeline.patch \
  /path/to/casebook/patches/cosmos-predict2/0002-video2world_action-example.patch
python -m py_compile \
  cosmos_predict2/pipelines/video2world_action.py \
  examples/video2world_action.py
```

## Out of scope

- Do not vendor the full cosmos-predict2 tree
- Do not treat formatting-only or absolute-path edits as patches
- These patches support **Bridge action-conditioned inference**, not DreamGen IDM or GR00T policy claims
