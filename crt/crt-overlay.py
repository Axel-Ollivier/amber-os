#!/usr/bin/env python3
# full-screen CRT overlay (all monitors), click-through: scanlines + light amber tint.
# static (drawn once) → negligible GPU/battery cost.
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GLib
import cairo


class CRTOverlay(Gtk.Window):
    def __init__(self):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)
        self.set_app_paintable(True)
        self.set_decorated(False)
        self.set_skip_taskbar_hint(True)
        self.set_skip_pager_hint(True)
        self.set_keep_above(True)
        self.set_accept_focus(False)
        self.set_focus_on_map(False)
        self.stick()  # visible on all workspaces

        screen = self.get_screen()
        visual = screen.get_rgba_visual()
        if visual is not None:
            self.set_visual(visual)

        # covers the entire multi-display area
        w, h = screen.get_width(), screen.get_height()
        self.move(0, 0)
        self.set_size_request(w, h)

        self.connect('draw', self.on_draw)
        self.connect('realize', self.make_click_through)

    def make_click_through(self, *_):
        win = self.get_window()
        if win is not None:
            win.input_shape_combine_region(cairo.Region(), 0, 0)

    def on_draw(self, _widget, cr):
        w = self.get_allocated_width()
        h = self.get_allocated_height()
        cr.set_operator(cairo.OPERATOR_SOURCE)
        cr.set_source_rgba(0, 0, 0, 0)
        cr.paint()
        cr.set_operator(cairo.OPERATOR_OVER)
        # scanlines (1px dark every 3px)
        cr.set_source_rgba(0, 0, 0, 0.22)
        y = 0
        while y < h:
            cr.rectangle(0, y, w, 1)
            y += 3
        cr.fill()
        # very light amber tint (#FFB454)
        cr.set_source_rgba(1.0, 0.706, 0.329, 0.04)
        cr.rectangle(0, 0, w, h)
        cr.fill()
        return False


if __name__ == '__main__':
    win = CRTOverlay()
    win.show_all()
    GLib.idle_add(win.make_click_through)
    Gtk.main()
