#!/usr/bin/env bash
# Safety net - restore Cinnamon if the Amber customization breaks something.
# Usage: ./rollback.sh [snapshot.dconf]   (default: snapshots/cinnamon-baseline.dconf)
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
SNAP="${1:-$DIR/snapshots/cinnamon-baseline.dconf}"

echo "→ Resetting to stock Mint theme…"
gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark'
gsettings set org.cinnamon.theme name 'Mint-Y-Dark'
gsettings set org.cinnamon.desktop.wm.preferences theme 'Mint-Y'
gsettings set org.cinnamon.desktop.interface icon-theme 'Mint-Y'
gsettings set org.cinnamon.desktop.interface cursor-theme 'Bibata-Modern-Classic'
gsettings set org.gnome.desktop.interface gtk-theme 'Mint-Y-Dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme 'Mint-Y' 2>/dev/null || true

if [ -f "$SNAP" ]; then
  echo "→ Full Cinnamon restore (panel, applets, menu) from:"
  echo "   $SNAP"
  dconf load /org/cinnamon/ < "$SNAP"
fi

echo "✓ Rollback complete."
echo "  Panel frozen? → Ctrl+Alt+Esc (restarts Cinnamon) or log out and back in."
