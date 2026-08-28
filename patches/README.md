# Patches

Only minimal, independently verifiable upstream diffs belong here.

## Policy

1. Target an exact revision from `manifests/upstream-revisions.md`.
2. Include `*.patch` plus `APPLY.md` with apply/check commands.
3. Reject formatting-only noise and absolute-path edits.
4. WAM / LingBot-VA changes stay **experimental or documentation-only** unless a loader test is added.

## Current status

| Patch | Upstream | Status |
|---|---|---|
| Cosmos Predict2 (2 minimal changes) | `661da477...` | Pending extraction on staging host — placeholder only |
| LingBot-VA adaptation | `7c6ffa9...` | Experimental / not default |
| FastWAM | `45d8e145...` | No runnable patch in this casebook |

When a patch is ready, add:

```text
patches/cosmos-predict2/<name>.patch
patches/cosmos-predict2/APPLY.md
```
