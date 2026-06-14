#!/usr/bin/env bash
# Builds "Amber-Icons": FULL FORK of Papirus recolored to MONOCHROME AMBER
# (single-hue ramp ~33°, relief preserved) + custom amber launchers.
set -uo pipefail
AMBER="#FFB454"
DIR="$(cd "$(dirname "$0")" && pwd)"
BASE="/usr/share/icons/Papirus"
TH="$HOME/.local/share/icons/Amber-Icons"

[ -d "$BASE" ] || { echo "✗ Papirus not found (sudo apt install papirus-icon-theme)"; exit 1; }

echo "→ Copying Papirus ($(du -sh "$BASE" 2>/dev/null | cut -f1))…"
rm -rf "$TH"
cp -r "$BASE" "$TH"

# index.theme: name + standalone set (now inherits only from hicolor)
sed -i 's/^Name=.*/Name=Amber-Icons/; s/^Inherits=.*/Inherits=hicolor/' "$TH/index.theme"
sed -i 's/^Comment=.*/Comment=Papirus recolored to amber monochrome/' "$TH/index.theme" 2>/dev/null || true
# Register apps/scalable (custom icons) in the index — otherwise GTK won't see them
# and Flatpak apps fall back to their colored icon (hicolor).
if ! grep -q '^\[apps/scalable\]' "$TH/index.theme" 2>/dev/null; then
  sed -i 's|^Directories=|Directories=apps/scalable,|' "$TH/index.theme"
  cat >> "$TH/index.theme" <<EOF

[apps/scalable]
Context=Applications
Size=128
MinSize=8
MaxSize=512
Type=Scalable
EOF
fi

NB=$(find "$TH" -name '*.svg' -type f | wc -l)
echo "→ Amber monochrome recolor (ramp) on $NB SVG…"
find "$TH" -name '*.svg' -type f -print0 \
  | xargs -0 -n 400 -P "$(nproc)" python3 "$DIR/icon-amberize.py" >/dev/null
echo "  recolor done."

# ── Overlay: hicolor apps/categories icons missing from Papirus ──
# (otherwise Settings modules, e.g. gnome-online-accounts-gtk, fall back to hicolor = colored).
echo "→ Overlay missing hicolor icons (apps/categories)…"
OVERLAY=()
while IFS= read -r -d '' f; do
  ctx="$(basename "$(dirname "$f")")"          # e.g.: categories, apps
  dest="$TH/scalable/$ctx/$(basename "$f")"
  if [ ! -e "$dest" ]; then
    mkdir -p "$TH/scalable/$ctx"; cp -L "$f" "$dest" && OVERLAY+=("$dest")
  fi
done < <(find /usr/share/icons/hicolor \( -path '*/apps/*.svg' -o -path '*/categories/*.svg' \) -print0 2>/dev/null)
echo "  overlay: ${#OVERLAY[@]} icon(s)"
[ ${#OVERLAY[@]} -gt 0 ] && python3 "$DIR/icon-amberize.py" "${OVERLAY[@]}" >/dev/null

# ── Custom amber launchers (pinned apps), over the recolored fork ──
mkdir -p "$TH/apps/scalable"
SIB="https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons"
get(){ if curl -fsSL "$SIB/$1.svg" -o /tmp/_si.svg 2>/dev/null && [ -s /tmp/_si.svg ]; then
  sed "s|<svg |<svg fill=\"$AMBER\" |" /tmp/_si.svg > "$TH/apps/scalable/$2.svg"; echo "  ok $2"; else echo "  KO $2 (offline?)"; fi; }
get spotify           spotify-client
get telegram          org.telegram.desktop
get discord           com.discordapp.Discord
get obsidian          md.obsidian.Obsidian
get plex              tv.plex.PlexDesktop
get bluetooth         blueman
get gnometerminal     org.gnome.Terminal
get zenbrowser        app.zen_browser.zen

# VS Code: devicon recolored amber
if curl -fsSL "https://raw.githubusercontent.com/devicons/devicon/master/icons/vscode/vscode-original.svg" -o /tmp/vsc.svg 2>/dev/null && [ -s /tmp/vsc.svg ]; then
  sed -E 's/fill="#[0-9A-Fa-f]+"/fill="'"$AMBER"'"/g; s/fill:#?[0-9A-Fa-f]+/fill:'"$AMBER"'/g' /tmp/vsc.svg \
    | sed "s|<svg |<svg fill=\"$AMBER\" |" > "$TH/apps/scalable/vscode.svg"; echo "  ok vscode"
fi

# Alias by WM_CLASS (the taskbar looks up the icon by WM_CLASS, not by .desktop)
alias_icon(){ [ -f "$TH/apps/scalable/$1.svg" ] && cp -f "$TH/apps/scalable/$1.svg" "$TH/apps/scalable/$2.svg" && echo "  alias $2 <- $1"; }
alias_icon app.zen_browser.zen zen        # Zen: WM_CLASS = "zen"

gtk-update-icon-cache -f -q "$TH" 2>/dev/null || true
echo "✓ Amber-Icons (Papirus amber monochrome fork): $TH ($(du -sh "$TH" 2>/dev/null | cut -f1))"
