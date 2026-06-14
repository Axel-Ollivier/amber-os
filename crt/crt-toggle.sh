#!/usr/bin/env bash
# toggles the global CRT overlay (scanlines + amber tint, click-through).
PIDFILE="/tmp/crt-overlay.pid"
OVERLAY="$HOME/.dotfiles/crt/crt-overlay.py"
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null; then
    kill "$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
    echo "CRT: OFF"
else
    nohup python3 "$OVERLAY" >/dev/null 2>&1 &
    echo $! > "$PIDFILE"
    echo "CRT: ON"
fi
