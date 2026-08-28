# Claim status table

Separate status language for each evidence class. Do not merge rows.

| Status ID | Statement | Evidence class | Manifest row | Supported? |
|---|---|---|---|---|
| S1 | DreamGen produced 126 MP4 videos for EVAL-175 GR1 inputs | engineering run | A2 | Yes (count/existence) |
| S2 | IDM wrote pseudo-actions into 126 LeRobot episodes | engineering run | A4 | Yes (schema writeback) |
| S3 | GR00T DataLoader can read the IDM episodes with matching schema | code + run | A4, A6 | Yes (load interface) |
| S4 | GR00T finetune reached 20k steps | engineering run | A7 | Yes (step count only) |
| S5 | Loss curve exported for the 20k run | engineering run | evidence/plots | Yes if plot present |
| S6 | Rollout / task success rate improved | not measured | — | **No** |
| S7 | Bridge test/13 action-conditioned inference produced an output video | engineering run | A10, A11 | Yes (one sample) |
| S8 | Bridge test/13 proves general dataset quality | — | — | **No** |
| S9 | WAM trains end-to-end on DreamGen trajectories | — | — | **No** (reference only) |

Captured: 2026-08-28
