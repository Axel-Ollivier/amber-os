#!/usr/bin/env python3
# EVENT-DRIVEN detection of display changes (zero polling) → relaunches the conky HUD.
# replaces the old `xrandr` polling every 4 s that blocked the X server
# (~170 ms x2 / 4 s on 4 displays) and caused micro-stutters.
import gi
gi.require_version('Gdk', '3.0')
from gi.repository import Gdk, GLib
import subprocess
import os

LAUNCH = os.path.expanduser("~/.dotfiles/conky/launch-conky-all.sh")
_pending = 0


def relaunch():
    global _pending
    _pending = 0
    subprocess.Popen(["bash", LAUNCH],
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return False  # do not repeat the timeout


def schedule(*_args):
    # debounce: coalesce closely spaced events from a single hotplug
    global _pending
    if _pending:
        GLib.source_remove(_pending)
    _pending = GLib.timeout_add(1500, relaunch)


display = Gdk.Display.get_default()
relaunch()  # initial launch of the HUD on each display
display.connect("monitor-added", schedule)
display.connect("monitor-removed", schedule)
GLib.MainLoop().run()
