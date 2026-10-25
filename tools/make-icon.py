#!/usr/bin/env python3
#
# make-icon.py - dibuja el ícono de OldieChat (PNG 192x192) sin librerías externas.
# Uso: make-icon.py <salida.png>

import math
import struct
import sys
import zlib

SIZE = 192
SS = 4  # supermuestreo para suavizar bordes

BG = (232, 131, 58)       # ámbar
BUBBLE = (255, 244, 224)  # crema
DOTS = (74, 52, 40)       # café oscuro


def in_round_rect(x, y, x0, y0, x1, y1, r):
    cx = min(max(x, x0 + r), x1 - r)
    cy = min(max(y, y0 + r), y1 - r)
    return (x - cx) ** 2 + (y - cy) ** 2 <= r * r


def in_triangle(x, y, a, b, c):
    def sign(p, q, r):
        return (p[0] - r[0]) * (q[1] - r[1]) - (q[0] - r[0]) * (p[1] - r[1])
    d1, d2, d3 = sign((x, y), a, b), sign((x, y), b, c), sign((x, y), c, a)
    neg = d1 < 0 or d2 < 0 or d3 < 0
    pos = d1 > 0 or d2 > 0 or d3 > 0
    return not (neg and pos)


def color_at(x, y):
    # x, y en coordenadas de 0..SIZE
    if not in_round_rect(x, y, 8, 8, 184, 184, 40):
        return None
    if in_round_rect(x, y, 34, 44, 158, 128, 30) or in_triangle(x, y, (58, 120), (92, 124), (48, 154)):
        for cx in (66, 96, 126):
            if (x - cx) ** 2 + (y - 86) ** 2 <= 11 ** 2:
                return DOTS
        return BUBBLE
    return BG


def render():
    rows = []
    for py in range(SIZE):
        row = bytearray([0])  # filtro PNG: ninguno
        for px in range(SIZE):
            acc = [0, 0, 0, 0]
            for sy in range(SS):
                for sx in range(SS):
                    c = color_at(px + (sx + 0.5) / SS, py + (sy + 0.5) / SS)
                    if c is not None:
                        acc[0] += c[0]; acc[1] += c[1]; acc[2] += c[2]; acc[3] += 255
            n = SS * SS
            a = acc[3] // n
            if a == 0:
                row += bytes(4)
            else:
                cov = acc[3] / 255
                row += bytes([round(acc[0] / cov), round(acc[1] / cov), round(acc[2] / cov), a])
        rows.append(bytes(row))
    return b"".join(rows)


def png(data):
    def chunk(kind, body):
        return struct.pack(">I", len(body)) + kind + body + struct.pack(">I", zlib.crc32(kind + body) & 0xFFFFFFFF)
    ihdr = struct.pack(">IIBBBBB", SIZE, SIZE, 8, 6, 0, 0, 0)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(data, 9)) + chunk(b"IEND", b"")


if __name__ == "__main__":
    with open(sys.argv[1], "wb") as f:
        f.write(png(render()))
