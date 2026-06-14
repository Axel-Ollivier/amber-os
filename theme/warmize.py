#!/usr/bin/env python3
"""warms a theme's colors: every neutral/cold gray -> warm amber step
of equivalent luminance. preserves saturated colors (amber/green/red/orange)
and light text (high luminance). idempotent (an already-warm tone is left untouched).

usage: warmize.py file1 [file2 ...]   (edits in place; .css and .svg)
"""
import re
import sys

# MINIMALIST warm scale: a single background #16110D for (almost) all grays,
# and only a few VISIBLE warm tones for secondary text / icons
# (which must stay legible on the dark background). anchored on the background #16110D.
STOPS = [
    (10,  "100B07"),  # shadows / near-black
    (84,  "16110D"),  # ALL backgrounds (window, sidebar, toolbar, menu, base) -> single background
    (112, "8A6E4C"),  # secondary / disabled text (dim, visible)
    (140, "B08A5C"),  # symbolic icons
    (168, "C9A876"),  # icons / light tertiary text
]

SAT_MAX = 22        # above this = brand color (amber/green/red…) -> keep
BRIGHT_MIN = 169    # max luminance >= 169 = light text/foreground -> keep


def warm(r, g, b):
    """returns warm (R,G,B) if the color is a neutral/cold gray to convert, otherwise None."""
    mx, mn = max(r, g, b), min(r, g, b)
    sat = mx - mn
    if sat > SAT_MAX:        # saturated color -> untouched
        return None
    if b < r - 2:            # already warm (r>b) -> untouched (idempotent)
        return None
    if mx >= BRIGHT_MIN:     # light text -> untouched
        return None
    for thr, hx in STOPS:
        if mx <= thr:
            return (int(hx[0:2], 16), int(hx[2:4], 16), int(hx[4:6], 16))
    return None


def _hex_sub(m):
    r, g, b = (int(m.group(1)[i:i + 2], 16) for i in (0, 2, 4))
    w = warm(r, g, b)
    return "#%02X%02X%02X" % w if w else m.group(0)


def _rgb_sub(m):
    r, g, b = int(m.group(2)), int(m.group(3)), int(m.group(4))
    w = warm(r, g, b)
    if not w:
        return m.group(0)
    return "%s(%d, %d, %d" % (m.group(1), w[0], w[1], w[2])


HEX = re.compile(r"#([0-9a-fA-F]{6})\b")
RGB = re.compile(r"(rgba|rgb)\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})")


def process(path):
    with open(path, encoding="utf-8") as f:
        src = f.read()
    out = RGB.sub(_rgb_sub, HEX.sub(_hex_sub, src))
    if out != src:
        with open(path, "w", encoding="utf-8") as f:
            f.write(out)
        return True
    return False


if __name__ == "__main__":
    changed = sum(process(p) for p in sys.argv[1:])
    print(f"  warmize: {changed}/{len(sys.argv) - 1} file(s) modified")
