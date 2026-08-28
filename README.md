# Embodied Data Synthesis Casebook

Private-first repository prepared for later public release. It combines the final four-part presentation narrative with sanitized orchestration, validation utilities, manifests, and small evidence artifacts.

Upstream source code, datasets, and checkpoints stay **external**.

## Canonical narrative

| Artifact | Location |
|---|---|
| Presentation content source (40 slides) | `docs/presentation-source.md` |
| Research survey + evidence vocabulary | `docs/research-survey.md` |
| Source-of-truth rules | `manifests/source-of-truth.md` |
| Claim status table | `manifests/claim-status.md` |

Final PowerPoint binary is **not** committed. See `manifests/source-of-truth.md`.

## What is reproducible here

### Default smoke (no network, no GPU)

```bash
bash pipelines/cosmos_bridge/run_inference.sh --dry-run --input tests/fixtures/bridge_test_13
bash pipelines/dreamgen_gr00t/run_all.sh --dry-run --fixture tests/fixtures/dreamgen
bash scripts/qa.sh
```

### Optional GPU routes (explicit paths required)

1. **Bridge action-conditioned inference** — real Bridge annotation → future video  
   See `pipelines/cosmos_bridge/README.md`. Requires staged sample + checkpoints. Never downloads the full Bridge archive by default.

2. **DreamGen → IDM → LeRobot → GR00T** — expensive optional path  
   See `pipelines/dreamgen_gr00t/README.md`. Real stages refuse non-empty overwrites and do not auto-download weights.

## Evidence boundaries

| Observation | Means | Does not mean |
|---|---|---|
| 126 MP4 | Generation complete | Task success |
| IDM `.data_idm` | Pseudo-actions written | Sensor ground truth |
| GR00T 20k steps | Training interface reached N steps | Policy improvement |
| Bridge test/13 | Action-conditioned video gen | Dataset quality / embodiment transfer |
| WAM docs | Reference architecture | Runnable consumer of DreamGen data |

Details: `manifests/claim-status.md`, `manifests/artifacts.md`.

## Repository layout

```text
docs/               cleaned survey + presentation source
pipelines/          DreamGen/GR00T and Cosmos Bridge launchers
scripts/            validation, metrics, path scan, qa.sh
manifests/          provenance, artifacts, claims
patches/            minimal upstream patches (when extracted)
evidence/           schemas, example metrics, plots, keyframes
tests/fixtures/     dry-run fixtures (no multi-GB binaries)
```

## Prerequisites

- Linux recommended for real GPU routes (Bash, Python 3.12+, optional Docker/conda)
- Windows can run dry-run + `scripts/qa.sh` via Git Bash / WSL
- External checkout of GR00T-Dreams / cosmos-predict2 at revisions in `manifests/upstream-revisions.md`
- GPU + large storage only for optional routes

## Upstream

Pin revisions before filing bugs against this casebook:

- GR00T-Dreams `ec3881d44545016871997f8e17dd15f1d792e91d`
- Cosmos Predict2 `661da4774b0ca41d082a0ecbeb47550bcf07e03f`

## License

Apache-2.0 for casebook-owned scripts and docs. Upstream projects retain their own licenses — verify before redistribution.
