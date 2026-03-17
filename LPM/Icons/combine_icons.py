"""
Combine icon halves: for each BMP in grays/, replace it with
the left 50% of pixels from Icons/<name> and the right 50% from blacks/<name>.

No external libraries required — uses raw BMP parsing (24-bit uncompressed only).
"""

import struct
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
GRAYS_DIR = os.path.join(SCRIPT_DIR, "grays")
BLACKS_DIR = os.path.join(SCRIPT_DIR, "blacks")
BASE_DIR = SCRIPT_DIR  # Icons/ folder itself


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


def combine(base_path, blacks_path, output_path):
    header, w, h, row_size, base_px = read_bmp(base_path)
    _, w2, h2, _, blacks_px = read_bmp(blacks_path)
    if (w, h) != (w2, h2):
        raise ValueError(f"Size mismatch: {base_path} ({w}x{h}) vs {blacks_path} ({w2}x{h2})")

    mid = w // 2  # left half pixel count
    out = bytearray(len(base_px))

    for y in range(h):
        row_off = y * row_size
        # Left half from base
        left_bytes = mid * 3
        out[row_off : row_off + left_bytes] = base_px[row_off : row_off + left_bytes]
        # Right half from blacks
        right_off = row_off + left_bytes
        right_bytes = (w - mid) * 3
        out[right_off : right_off + right_bytes] = blacks_px[right_off : right_off + right_bytes]
        # Copy any row padding from base
        pad_off = row_off + w * 3
        out[pad_off : row_off + row_size] = base_px[pad_off : row_off + row_size]

    with open(output_path, "wb") as f:
        f.write(header)
        f.write(out)


def main():
    files = sorted(f for f in os.listdir(GRAYS_DIR) if f.lower().endswith(".bmp"))
    for name in files:
        base_path = os.path.join(BASE_DIR, name)
        blacks_path = os.path.join(BLACKS_DIR, name)
        gray_path = os.path.join(GRAYS_DIR, name)

        if not os.path.isfile(base_path):
            print(f"SKIP {name}: not found in Icons/")
            continue
        if not os.path.isfile(blacks_path):
            print(f"SKIP {name}: not found in blacks/")
            continue

        combine(base_path, blacks_path, gray_path)
        print(f"OK   {name}")


if __name__ == "__main__":
    main()
