#!/usr/bin/env bash
# apply the Amber palette to the default GNOME Terminal profile.
set -uo pipefail
PROF=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")
[ -z "$PROF" ] && { echo "✗ GNOME Terminal profile not found"; exit 1; }
B="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROF/"
gsettings set "$B" use-theme-colors false
gsettings set "$B" background-color '#16110D'
gsettings set "$B" foreground-color '#FFB454'
gsettings set "$B" bold-color-same-as-fg true
gsettings set "$B" cursor-colors-set true
gsettings set "$B" cursor-background-color '#FFB454'
gsettings set "$B" cursor-foreground-color '#16110D'
gsettings set "$B" use-system-font false
gsettings set "$B" font 'JetBrainsMono Nerd Font 12'
gsettings set "$B" palette "['#16110D','#E8743B','#8FB36B','#FFB454','#CC785C','#C2603A','#C98A52','#E8D5BC','#5a4632','#F0824A','#A6C77F','#FFD089','#D98E6E','#D67A50','#D9A86A','#F5E9D6']"
echo "✓ GNOME Terminal themed Amber (profile $PROF)"
