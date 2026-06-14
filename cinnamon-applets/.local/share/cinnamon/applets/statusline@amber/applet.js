const Applet = imports.ui.applet;
const St = imports.gi.St;
const Clutter = imports.gi.Clutter;
const GLib = imports.gi.GLib;

// A segment = an St.Label: inline color + monospace font via markup + vertically centered.
function seg(text, color) {
    let l = new St.Label({ style: "color: " + color + "; font-weight: normal;" });
    try { l.set_y_align(Clutter.ActorAlign.CENTER); l.set_y_expand(true); } catch (e) {}
    let ct = l.clutter_text;
    ct.set_use_markup(true);
    ct.set_markup("<span font_family='JetBrainsMono Nerd Font' font_weight='normal'>" + text + "</span>");
    return l;
}

function StatusApplet(metadata, orientation, panelHeight, instanceId) {
    this._init(metadata, orientation, panelHeight, instanceId);
}

StatusApplet.prototype = {
    __proto__: Applet.Applet.prototype,

    _init: function(metadata, orientation, panelHeight, instanceId) {
        Applet.Applet.prototype._init.call(this, orientation, panelHeight, instanceId);
        let user = GLib.get_user_name();
        let box = new St.BoxLayout({ style: "spacing: 5px;" });
        try { box.set_y_align(Clutter.ActorAlign.CENTER); box.set_y_expand(true); } catch (e) {}
        box.add_actor(seg("❯", "#8FB36B"));   // ❯ green
        box.add_actor(seg(user, "#FFB454"));        // user amber
        box.add_actor(seg("~", "#C98A52"));         // ~ dim
        this.actor.add_actor(box);
        global.log("AMBER-SL5: prompt vertically centered");
        this.set_applet_tooltip("Amber statusline");
    }
};

function main(metadata, orientation, panelHeight, instanceId) {
    return new StatusApplet(metadata, orientation, panelHeight, instanceId);
}
