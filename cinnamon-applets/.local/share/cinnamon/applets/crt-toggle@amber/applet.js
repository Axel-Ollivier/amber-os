const Applet = imports.ui.applet;
const Util = imports.misc.util;
const GLib = imports.gi.GLib;

function CrtApplet(metadata, orientation, panelHeight, instanceId) {
    this._init(metadata, orientation, panelHeight, instanceId);
}

CrtApplet.prototype = {
    __proto__: Applet.TextIconApplet.prototype,

    _init: function(metadata, orientation, panelHeight, instanceId) {
        Applet.TextIconApplet.prototype._init.call(this, orientation, panelHeight, instanceId);
        this.pidfile = "/tmp/crt-overlay.pid";
        this.script = GLib.get_home_dir() + "/.dotfiles/crt/crt-toggle.sh";
        this.set_applet_tooltip("CRT overlay - click to toggle on / off");
        this._update();
        this._loop = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 3, () => {
            this._update();
            return true;
        });
    },

    _isOn: function() {
        if (!GLib.file_test(this.pidfile, GLib.FileTest.EXISTS)) return false;
        let res = GLib.file_get_contents(this.pidfile);
        if (!res[0]) return false;
        let text = (typeof TextDecoder !== "undefined")
            ? new TextDecoder().decode(res[1])
            : imports.byteArray.toString(res[1]);
        let pid = parseInt(text.trim());
        if (!pid) return false;
        return GLib.file_test("/proc/" + pid, GLib.FileTest.EXISTS);
    },

    _update: function() {
        this.set_applet_label(this._isOn() ? "CRT ●" : "CRT ○");
    },

    on_applet_clicked: function() {
        Util.spawnCommandLine("bash " + this.script);
        GLib.timeout_add(GLib.PRIORITY_DEFAULT, 400, () => {
            this._update();
            return false;
        });
    },

    on_applet_removed_from_panel: function() {
        if (this._loop) {
            GLib.source_remove(this._loop);
            this._loop = 0;
        }
    }
};

function main(metadata, orientation, panelHeight, instanceId) {
    return new CrtApplet(metadata, orientation, panelHeight, instanceId);
}
