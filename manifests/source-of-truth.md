# Source of truth

This repository treats the following as the **only** canonical presentation narrative.

| Role | Artifact | In Git? | Notes |
|---|---|---|---|
| Final deck | `具身智能数据合成方法-公司汇报-最终版.pptx` | **No** | Local/desktop reference only; binaries stay out of Git until redistribution rights are confirmed |
| Content source | `docs/presentation-source.md` (from `具身智能数据合成方法-正式汇报-v2-PPT编辑稿.md`) | Yes | 40-slide structure, four Parts |
| Research survey | `docs/research-survey.md` (from `具身智能数据合成方法调研.md`) | Yes | Evidence vocabulary and claim boundaries |

## Older decks / drafts (reference-only)

Do **not** use these as narrative sources of truth:

- Any `*-v1*`, `*-v4*`, `*-插图版*`, or intermediate PPT builders under `_ppt_build/`
- Temporary handoff notes under AppData or `99_Temp/`
- NDJSON inspect dumps that embed private absolute paths

## Four-Part structure (must be preserved)

| Part | Theme |
|---|---|
| Part 1 | Why synthesis is needed; industry-chain position |
| Part 2 | Trainable trajectory data contract |
| Part 3 | Method taxonomy, action supervision, evaluation gates |
| Part 4 | DreamGen / GR00T / Cosmos engineering validation and boundaries |

## Claim vocabulary (must stay separate)

| Claim type | Means | Does not mean |
|---|---|---|
| Video generation complete | MP4 files exist and decode | Task success |
| IDM writeback | Pseudo-actions in LeRobot schema | Sensor ground truth |
| GR00T N steps | Training interface/run reached N steps | Policy gain |
| Bridge test/13 | Action-conditioned video generation ran | Embodiment transfer / policy eval |

Captured: 2026-08-28
