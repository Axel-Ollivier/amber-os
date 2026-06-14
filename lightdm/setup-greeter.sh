#!/usr/bin/env bash
# Amber OS login screen (LightDM / slick-greeter): flat wordmark centered on warm black.
# Run with sudo:  sudo bash lightdm/setup-greeter.sh [WIDTHxHEIGHT]
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
RES="${1:-3840x1080}"
BG=/usr/share/backgrounds/amber-os-lockscreen.png

command -v convert >/dev/null || { echo "✗ ImageMagick (convert) required"; exit 1; }
[ -f "$DIR/docs/wordmark-flat.png" ] || { echo "✗ docs/wordmark-flat.png not found"; exit 1; }

# Compose: flat wordmark centered on a warm-black canvas
convert -size "$RES" xc:'#16110D' \
  \( "$DIR/docs/wordmark-flat.png" -resize 1000x \) -gravity center -composite "$BG"

# Point slick-greeter at it
cat > /etc/lightdm/slick-greeter.conf <<EOF
[Greeter]
theme-name=Mint-Y-Dark-Orange
background=$BG
background-color=#16110D
draw-user-backgrounds=false
draw-grid=false
EOF

echo "✓ Amber OS greeter installed ($BG @ $RES)"
