# Upstream revisions

Exact revisions used for the engineering cases. Clone these repositories externally; do not vendor them into this casebook.

| Project | Upstream URL | Revision | Role in this casebook | License (verify upstream) |
|---|---|---|---|---|
| GR00T-Dreams | https://github.com/NVIDIA/GR00T-Dreams | `ec3881d44545016871997f8e17dd15f1d792e91d` | DreamGen video → IDM → LeRobot → GR00T finetune orchestration | Apache-2.0 (verify) |
| Cosmos Predict2 | https://github.com/nvidia-cosmos/cosmos-predict2 | `661da4774b0ca41d082a0ecbeb47550bcf07e03f` | Action-conditioned Bridge inference | NVIDIA open-source terms (verify) |
| FastWAM | https://github.com/starwam/FastWAM (verify URL) | `45d8e1458921d83f8ad6cf9ce993d371208dabd0` | WAM reference only — **not runnable in this casebook** | Verify upstream |
| LingBot-VA | verify upstream URL | `7c6ffa9bfc4b83582cafc860fab4c82cc7deeeeb` | WAM/docs reference; any local adaptation is experimental | Verify upstream |

## Patch policy

- Only minimal, independently verifiable diffs belong under `patches/`.
- Each patch must state: target revision, files touched, apply command, check command, and why it is required.
- Formatting-only noise and absolute path edits are rejected.

## Access class

| Class | Meaning |
|---|---|
| `public` | Freely cloneable / downloadable under stated license |
| `permission-required` | Needs HF/org access or license acceptance |
| `internal-generated` | Produced by local/remote runs; not redistributed by default |

Captured: 2026-08-28 · SHA256 fields for large artifacts live in `artifacts.md` (`pending` until hashed on the staging host).
