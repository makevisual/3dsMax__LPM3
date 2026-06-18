"""
Build the "half-disabled" tri-state icons (objectSet/lightSet "--" state).

For each color in COLORS, writes Icons/<color>-disabled/<name>, where each icon
is the left 50% of pixels from the non-Off base icon in Icons/ and the right 50%
from Icons/<color>/<name>.

For "FooOff.bmp", the base icon is "Foo.bmp". If that doesn't exist,
falls back to "FooOn.bmp", then "FooOff.bmp" itself.

The filename set is taken from Icons/blacks-disabled/ so every <color>-disabled
folder stays symmetric. Run this whenever a color's Off icons change.

No external libraries required — uses raw BMP parsing (24-bit uncompressed only).
"""

import struct
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_DIR = SCRIPT_DIR  # Icons/ folder itself
# Drives which <color>/ folders are combined into <color>-disabled/ folders.
COLORS = ["blacks", "reds"]
# The canonical filename set every *-disabled folder mirrors.
TEMPLATE_DIR = os.path.join(SCRIPT_DIR, "blacks-disabled")


def read_bmp(path):
    with open(path, "rb") as f:
        data = f.read()
    width = struct.unpack_from("<I", data, 18)[0]
    height = struct.unpack_from("<I", data, 22)[0]
    bpp = struct.unpack_from("<H", data, 28)[0]
    offset = struct.unpack_from("<I", data, 10)[0]
    if bpp != 24:
        raise ValueError(f"{path}: expected 24-bit BMP, got {bpp}-bit")
    row_size = (width * 3 + 3) & ~3  # rows are padded to 4-byte boundaries
    pixels = data[offset:]
    return data[:offset], width, height, row_size, bytearray(pixels)


def combine(base_path, color_path, output_path):
    header, w, h, row_size, base_px = read_bmp(base_path)
    _, w2, h2, _, color_px = read_bmp(color_path)
    if (w, h) != (w2, h2):
        raise ValueError(f"Size mismatch: {base_path} ({w}x{h}) vs {color_path} ({w2}x{h2})")

    mid = w // 2  # left half pixel count
    out = bytearray(len(base_px))

    for y in range(h):
        row_off = y * row_size
        # Left half from base
        left_bytes = mid * 3
        out[row_off : row_off + left_bytes] = base_px[row_off : row_off + left_bytes]
        # Right half from color
        right_off = row_off + left_bytes
        right_bytes = (w - mid) * 3
        out[right_off : right_off + right_bytes] = color_px[right_off : right_off + right_bytes]
        # Copy any row padding from base
        pad_off = row_off + w * 3
        out[pad_off : row_off + row_size] = base_px[pad_off : row_off + row_size]

    with open(output_path, "wb") as f:
        f.write(header)
        f.write(out)


def find_base_icon(name):
    """Find the base (non-Off) icon for a given disabled icon filename."""
    stem = name[:-4]  # strip .bmp
    if stem.endswith("Off"):
        base_stem = stem[:-3]  # e.g. "CameraOverscanOff" -> "CameraOverscan"
        # Try plain name first, then On variant, then fall back to Off
        for suffix in ["", "On", "Off"]:
            candidate = os.path.join(BASE_DIR, base_stem + suffix + ".bmp")
            if os.path.isfile(candidate):
                return candidate
    # No Off suffix (e.g. "Disabled.bmp") — use as-is
    candidate = os.path.join(BASE_DIR, name)
    if os.path.isfile(candidate):
        return candidate
    return None


def build_color(color):
    color_dir = os.path.join(SCRIPT_DIR, color)
    out_dir = os.path.join(SCRIPT_DIR, color + "-disabled")
    os.makedirs(out_dir, exist_ok=True)

    files = sorted(f for f in os.listdir(TEMPLATE_DIR) if f.lower().endswith(".bmp"))
    for name in files:
        base_path = find_base_icon(name)
        color_path = os.path.join(color_dir, name)
        out_path = os.path.join(out_dir, name)

        if base_path is None:
            print(f"SKIP {color}/{name}: no base icon found in Icons/")
            continue
        if not os.path.isfile(color_path):
            print(f"SKIP {color}/{name}: not found in {color}/")
            continue

        combine(base_path, color_path, out_path)
        base_label = os.path.basename(base_path)
        print(f"OK   {color}-disabled/{name}  (base: {base_label})")


def main():
    for color in COLORS:
        build_color(color)


if __name__ == "__main__":
    main()
