#!/usr/bin/env bash
# Create a restore point for Cinnamon settings (dconf).
# Usage: ./snapshot.sh [name]   (default: baseline)
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)/snapshots"
mkdir -p "$DIR"
NAME="${1:-baseline}"
OUT="$DIR/cinnamon-${NAME}.dconf"
dconf dump /org/cinnamon/ > "$OUT"
echo "✓ Cinnamon snapshot: $OUT ($(wc -l < "$OUT") lines)"
