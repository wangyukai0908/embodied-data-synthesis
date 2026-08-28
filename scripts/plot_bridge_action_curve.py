#!/usr/bin/env python3
"""Plot first 12 x 7D Bridge action condition curve from an annotation JSON."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("annotation", type=Path, help="Bridge annotation JSON (e.g. 13.json)")
    parser.add_argument("-o", "--output", type=Path, required=True, help="Output PNG path")
    parser.add_argument("--ee-scale", type=float, default=20.0, help="Scale for action_ee dims (default 20)")
    args = parser.parse_args()

    import numpy as np
    from PIL import Image, ImageDraw, ImageFont

    annotation = json.loads(args.annotation.read_text(encoding="utf-8"))
    action_ee = np.asarray(annotation["action"], dtype=np.float64)[:12, :6] * args.ee_scale
    gripper = np.asarray(annotation["continuous_gripper_state"], dtype=np.float64)[1:13, None]
    actions = np.concatenate([action_ee, gripper], axis=1)

    width, height = 1600, 900
    image = Image.new("RGB", (width, height), "white")
    draw = ImageDraw.Draw(image)
    font = ImageFont.load_default()
    colors = ["#0B6E69", "#D65A31", "#276FBF", "#7A5195", "#2E8540", "#A05128", "#333333"]
    labels = ["dx", "dy", "dz", "droll", "dpitch", "dyaw", "gripper"]
    left, right, top, bottom = 90, 1540, 90, 810
    draw.text((left, 25), "Bridge action condition: first 12 x 7D", fill="#1E2933", font=font)
    for dim in range(actions.shape[1]):
        values = actions[:, dim]
        lo, hi = float(values.min()), float(values.max())
        span = max(hi - lo, 1e-9)
        band_top = top + dim * (bottom - top) / 7
        band_bottom = top + (dim + 1) * (bottom - top) / 7
        draw.line((left, band_bottom, right, band_bottom), fill="#DDE3E8", width=1)
        points = []
        for step, value in enumerate(values):
            x = left + step * (right - left) / 11
            y = band_bottom - 15 - (float(value) - lo) / span * max(band_bottom - band_top - 30, 1)
            points.append((round(x), round(y)))
        draw.line(points, fill=colors[dim], width=4)
        draw.text((10, round((band_top + band_bottom) / 2)), labels[dim], fill=colors[dim], font=font)
        draw.text((right - 180, round(band_top + 5)), f"[{lo:.4f}, {hi:.4f}]", fill="#52616D", font=font)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    image.save(args.output)
    print(f"wrote {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
