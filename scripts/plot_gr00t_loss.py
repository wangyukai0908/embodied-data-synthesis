#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "pillow>=10",
#     "numpy>=1.26",
# ]
# ///
"""Plot GR00T trainer_state.json loss curves for evidence/plots."""

from __future__ import annotations

import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Final

import numpy as np
from PIL import Image, ImageDraw, ImageFont

WINDOW: Final = 51
CANVAS_SIZE: Final = (1980, 1045)
PLOT_LEFT: Final = 175
PLOT_TOP: Final = 160
PLOT_RIGHT: Final = 1850
PLOT_BOTTOM: Final = 850


@dataclass(frozen=True, slots=True)
class LossPoint:
    step: int
    loss: float


def read_loss_points(state_path: Path) -> list[LossPoint]:
    raw_state = json.loads(state_path.read_text(encoding="utf-8"))
    history = raw_state["log_history"]
    return [
        LossPoint(step=int(entry["step"]), loss=float(entry["loss"]))
        for entry in history
        if "loss" in entry and "step" in entry
    ]


def rolling_mean(values: np.ndarray) -> np.ndarray:
    weights = np.full(WINDOW, 1.0 / WINDOW)
    return np.convolve(values, weights, mode="same")


def point_to_pixel(step: int, loss: float, last_step: int, max_loss: float) -> tuple[int, int]:
    x = PLOT_LEFT + (PLOT_RIGHT - PLOT_LEFT) * step / last_step
    y = PLOT_BOTTOM - (PLOT_BOTTOM - PLOT_TOP) * loss / max_loss
    return round(x), round(y)


def system_font(size: int, *, bold: bool = False) -> ImageFont.ImageFont:
    names = ("arialbd.ttf", "DejaVuSans-Bold.ttf") if bold else ("arial.ttf", "DejaVuSans.ttf")
    search_dirs = (
        Path("C:/Windows/Fonts"),
        Path("/usr/share/fonts/truetype/dejavu"),
        Path("/usr/share/fonts/truetype/liberation"),
    )
    for directory in search_dirs:
        for name in names:
            candidate = directory / name
            if candidate.is_file():
                return ImageFont.truetype(str(candidate), size=size)
    return ImageFont.load_default()


def draw(points: list[LossPoint], output_path: Path) -> None:
    steps = np.array([point.step for point in points], dtype=float)
    losses = np.array([point.loss for point in points], dtype=float)
    smoothed = rolling_mean(losses)
    last_step = int(steps[-1])
    max_loss = float(losses.max())

    image = Image.new("RGB", CANVAS_SIZE, "white")
    canvas = ImageDraw.Draw(image)
    canvas.rectangle((PLOT_LEFT, PLOT_TOP, PLOT_RIGHT, PLOT_BOTTOM), outline="#333333", width=2)

    raw_xy = [point_to_pixel(int(s), float(l), last_step, max_loss) for s, l in zip(steps, losses, strict=True)]
    smooth_xy = [
        point_to_pixel(int(s), float(l), last_step, max_loss) for s, l in zip(steps, smoothed, strict=True)
    ]
    canvas.line(raw_xy, fill="#9AA5B1", width=2)
    canvas.line(smooth_xy, fill="#0E5A8A", width=4)
    canvas.text((PLOT_LEFT, 40), "GR00T training loss (step count ≠ policy gain)", fill="#172033", font=system_font(36, bold=True))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    image.save(output_path)


def main(argv: list[str]) -> int:
    if len(argv) != 3 or argv[1] in {"-h", "--help"}:
        print("Usage: plot_gr00t_loss.py <trainer_state.json> <output.png>")
        return 0 if len(argv) > 1 and argv[1] in {"-h", "--help"} else 2
    state_path = Path(argv[1])
    output_path = Path(argv[2])
    points = read_loss_points(state_path)
    if not points:
        print("No loss entries found", file=sys.stderr)
        return 1
    draw(points, output_path)
    print(f"wrote {output_path} points={len(points)} last_step={points[-1].step}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
