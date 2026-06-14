#!/usr/bin/env bash
# builds the "Amber" Cinnamon theme: fork of Mint-Y-Dark-Sand
#   1) sand accent -> amber (+ leftovers missed by the original swap)
#   2) warm-black conversion: cold gray base -> warm amber scale (hex + rgb)
#   3) GTK: warm semantic roles via @define-color
#   4) Cinnamon overrides (panel/statusline/tooltips)
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

SRC=""
for c in "$HOME/.themes/Mint-Y-Dark-Sand" "/usr/share/themes/Mint-Y-Dark-Sand"; do
    [ -d "$c" ] && SRC="$c" && break
done
[ -z "$SRC" ] && { echo "✗ Mint-Y-Dark-Sand not found"; exit 1; }

DEST="$HOME/.themes/Amber"
rm -rf "$DEST"
cp -rL "$SRC" "$DEST"

# themeable text files (css/xml/svg/gtkrc/themerc)
mapfile -d '' FILES < <(find "$DEST" -type f \
    \( -name '*.css' -o -name '*.xml' -o -name '*.svg' -o -name 'gtkrc' -o -name 'themerc' \) -print0)

# ── 1) sand accent -> amber (original swap + leftovers: c8ac69 accent, cdad8e/cbaa8a checkboxes) ──
sed -i -E '
  s/c5a07c/FFB454/Ig;
  s/197, ?160, ?124/255, 180, 84/g;
  s/c8ac69/FFB454/Ig;
  s/cdad8e/FFC97A/Ig;
  s/cbaa8a/FFC97A/Ig;
' "${FILES[@]}"

# ── 2) warm scale: every neutral/cold gray -> warm amber step (algorithmic) ──
#   warmize.py: luminance-equivalent, preserves saturated colors + light text, idempotent.
#   target: the 3 CSS files + the Cinnamon chrome SVGs (menus, notifications, switch, checkbox).
WARM_TARGETS=("$DEST/cinnamon/cinnamon.css")
for g in gtk-3.0/gtk.css gtk-3.0/gtk-dark.css gtk-4.0/gtk.css gtk-4.0/gtk-dark.css; do
  [ -f "$DEST/$g" ] && WARM_TARGETS+=("$DEST/$g")
done
while IFS= read -r -d '' svg; do WARM_TARGETS+=("$svg"); done \
  < <(find "$DEST/cinnamon/dark-assets" "$DEST/cinnamon/common-assets" -name '*.svg' -print0 2>/dev/null)
python3 "$DIR/warmize.py" "${WARM_TARGETS[@]}"

# ── 2b) shell text: light -> amber (warmize protects light text; here we want it amber) ──
sed -i -E '
  s/#e1e1e1/#FFB454/Ig;
  s/#d3d3d3/#C98A52/Ig;
  s/rgba\(225, ?225, ?225,/rgba(255, 180, 84,/g;
' "$DEST/cinnamon/cinnamon.css"

# ── 3) GTK: warm semantic roles (the role takes precedence over the luminance mapping) ──
for gtkcss in "$DEST/gtk-3.0/gtk.css" "$DEST/gtk-3.0/gtk-dark.css" "$DEST/gtk-4.0/gtk.css" "$DEST/gtk-4.0/gtk-dark.css"; do
  [ -f "$gtkcss" ] || continue
  sed -i -E '
    s/@define-color (theme_bg_color|bg_color|theme_unfocused_bg_color) .*/@define-color \1 #16110D;/;
    s/@define-color (theme_base_color|base_color|insensitive_base_color|theme_unfocused_base_color|content_view_bg) .*/@define-color \1 #16110D;/;
    s/@define-color (insensitive_bg_color) .*/@define-color \1 #1F1813;/;
    s/@define-color (borders|unfocused_borders) .*/@define-color \1 #33271A;/;
    s/@define-color (wm_bg|wm_bg_unfocused) .*/@define-color \1 #16110D;/;
    s/@define-color (selected_fg_color|theme_selected_fg_color) .*/@define-color \1 #16110D;/;
    s/@define-color (accent_color) .*/@define-color \1 #FFB454;/;
    s/@define-color (theme_fg_color|fg_color|theme_text_color|text_color|theme_unfocused_fg_color|theme_unfocused_text_color) .*/@define-color \1 #FFB454;/;
    s/@define-color (placeholder_text_color) .*/@define-color \1 #C98A52;/;
    s/@define-color (insensitive_fg_color) .*/@define-color \1 #8A6E4C;/;
    s/@define-color (wm_title) .*/@define-color \1 #FFB454;/;
    s/@define-color (wm_title_unfocused) .*/@define-color \1 #C98A52;/;
  ' "$gtkcss"
  # hardcoded light text -> amber (alpha preserved = text/disabled hierarchy kept)
  sed -i -E '
    s/(color: ?)rgba\(255, ?255, ?255,/\1rgba(255, 180, 84,/Ig;
    s/(color: ?)#DADADA/\1#FFB454/Ig;
    s/(color: ?)#E1E1E1/\1#FFB454/Ig;
    s/(color: ?)#D3D3D3/\1#C98A52/Ig;
  ' "$gtkcss"
  # minimalist flat background + amber menus (rules at end of file win)
  printf '\n' >> "$gtkcss"
  cat "$DIR/amber-gtk-overrides.css" >> "$gtkcss"
done

# ── 4) Cinnamon overrides (panel / statusline / tooltips) ──
printf '\n' >> "$DEST/cinnamon/cinnamon.css"
cat "$DIR/amber-overrides.css" >> "$DEST/cinnamon/cinnamon.css"

# display name
if [ -f "$DEST/index.theme" ]; then
    sed -i 's/^Name=.*/Name=Amber/' "$DEST/index.theme" 2>/dev/null || true
fi

echo "✓ Amber theme built ($DEST, source: $SRC)"
