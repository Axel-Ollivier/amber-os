#!/usr/bin/env bash
# launches one "AMBER OS" conky per connected display (one per xinerama_head).
CONF="$HOME/.config/conky/amber.conf"
pkill -x conky 2>/dev/null

N=$(xrandr --listmonitors 2>/dev/null | awk 'NR==1{print $2}')
case "$N" in ''|*[!0-9]*) N=1 ;; esac

for h in $(seq 0 $((N - 1))); do
    tmp="/tmp/conky-amber-head${h}.conf"
    sed "s/xinerama_head *= *[0-9]*/xinerama_head = ${h}/" "$CONF" > "$tmp"
    conky -c "$tmp" -d -p 1 >/dev/null 2>&1
done
echo "conky launched on $N display(s)"
