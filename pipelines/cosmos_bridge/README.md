# Cosmos action-conditioned Bridge inference

Minimal one-sample route for Bridge `test/13`.

## Default smoke

```bash
bash pipelines/cosmos_bridge/run_inference.sh --dry-run --input tests/fixtures/bridge_test_13
```

## Real run prerequisites

- Upstream cosmos-predict2 at revision in `manifests/upstream-revisions.md`
- Staged `rgb.mp4` + annotation JSON (no implicit 30+ GiB archive download)
- Action-conditioned checkpoint + Video2World tokenizer under `CHECKPOINT_ROOT`
- Explicit `--allow-download` only when you intentionally fetch checkpoints

## Metrics contract

Canonical metrics (after a real run) belong in `evidence/metrics/bridge_test_13.json` with:

- sample_id, input/output frames, resolution, fps, action_dim
- checkpoint/tokenizer revision, command, content hashes
- claim: action-conditioned video generation only
