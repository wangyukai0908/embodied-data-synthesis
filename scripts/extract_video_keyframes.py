#!/usr/bin/env python3
"""Extract first / middle / last frames (+ optional contact sheet) from a video."""

from __future__ import annotations

import argparse
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("video", type=Path, help="Input video path")
    parser.add_argument("-o", "--output-dir", type=Path, required=True, help="Output directory")
    parser.add_argument("--prefix", default="frame", help="Filename prefix (default: frame)")
    parser.add_argument("--contact-sheet", action="store_true", help="Also write a side-by-side contact sheet")
    args = parser.parse_args()

    import imageio.v3 as iio
    import numpy as np

    frames = iio.imread(args.video, plugin="pyav")
    if frames.ndim != 4 or frames.shape[0] < 1:
        raise SystemExit(f"unexpected frame tensor shape: {getattr(frames, 'shape', None)}")

    out = args.output_dir
    out.mkdir(parents=True, exist_ok=True)
    first, middle, last = frames[0], frames[len(frames) // 2], frames[-1]
    iio.imwrite(out / f"{args.prefix}_first.png", first)
    iio.imwrite(out / f"{args.prefix}_middle.png", middle)
    iio.imwrite(out / f"{args.prefix}_last.png", last)

    if args.contact_sheet:
        sep = np.full((frames.shape[1], 12, 3), 255, dtype=frames.dtype)
        sheet = np.concatenate([first, sep, middle, sep, last], axis=1)
        iio.imwrite(out / f"{args.prefix}_contact_sheet.png", sheet)

    print(f"wrote keyframes to {out} shape={frames.shape}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
