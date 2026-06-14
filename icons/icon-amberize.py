#!/usr/bin/env python3
"""Recolors SVGs to MONOCHROME AMBER: each color -> amber shade of
equivalent luminance (single-hue ramp ~33°). The icon's relief is
preserved (light amber highlights, dark amber shadows), visible on a dark background.

Usage: icon-amberize.py file.svg [...]   (edits in place)
Preserves: transparency, fill:none, currentColor.
"""
import re
import sys
import colorsys

HUE = 33 / 360.0  # amber (#FFB454)


def ramp(r, g, b):
    # perceived luminance 0..1
    L = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255.0
    s = 0.70 - 0.22 * L          # dark parts more saturated
    v = 0.38 + 0.60 * L          # min 0.38 -> even blacks stay visible
    rr, gg, bb = colorsys.hsv_to_rgb(HUE, max(0.0, min(1.0, s)), max(0.0, min(1.0, v)))
    return int(round(rr * 255)), int(round(gg * 255)), int(round(bb * 255))


def _hex8(m):
    h = m.group(1)
    r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4))
    return "#%02x%02x%02x%s" % (*ramp(r, g, b), h[6:8])


def _hex6(m):
    r, g, b = (int(m.group(1)[i:i + 2], 16) for i in (0, 2, 4))
    return "#%02x%02x%02x" % ramp(r, g, b)


def _hex3(m):
    r, g, b = (int(c * 2, 16) for c in m.group(1))
    return "#%02x%02x%02x" % ramp(r, g, b)


def _named(m):
    pre, name = m.group(1), m.group(2).lower()
    rgb = {"white": (255, 255, 255), "black": (0, 0, 0), "gray": (128, 128, 128),
           "grey": (128, 128, 128), "silver": (192, 192, 192)}.get(name)
    if not rgb:
        return m.group(0)
    return "%s#%02x%02x%02x" % (pre, *ramp(*rgb))


HEX8 = re.compile(r"#([0-9a-fA-F]{8})\b")
HEX6 = re.compile(r"#([0-9a-fA-F]{6})\b")
HEX3 = re.compile(r"#([0-9a-fA-F]{3})\b")
NAMED = re.compile(r"(fill[:=]\"?|stroke[:=]\"?|stop-color[:=]\"?)(white|black|gray|grey|silver)\b", re.I)


def process(path):
    with open(path, encoding="utf-8") as f:
        s = f.read()
    out = NAMED.sub(_named, HEX3.sub(_hex3, HEX6.sub(_hex6, HEX8.sub(_hex8, s))))
    if out != s:
        with open(path, "w", encoding="utf-8") as f:
            f.write(out)
        return True
    return False


if __name__ == "__main__":
    n = sum(process(p) for p in sys.argv[1:])
    print(f"  amberize: {n}/{len(sys.argv) - 1} svg recolored")
