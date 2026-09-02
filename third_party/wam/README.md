# WAM source snapshots

This directory contains source-only snapshots used while checking whether
DreamGen/LeRobot trajectories can be consumed by representative video-action
models. The snapshots are not the upstream projects of record; each project
keeps its own license, README, and revision metadata.

Included projects:

- `FastWAM/` — direct video representation to action prediction.
- `lingbot-va/` — visual-action model with causal state and interface code.
- `mimic-video/` — Cosmos feature to action decoder pipeline.

Datasets, checkpoints, caches, generated outputs, nested `.git` directories,
and large media files are intentionally excluded. For full history and model
weights, use the upstream repositories and the revisions recorded in
`manifests/upstream-revisions.md`.
