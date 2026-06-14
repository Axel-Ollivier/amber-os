<p align="center"><img src="docs/wordmark-glow.png" alt="Amber OS" width="440"></p>

<p align="center">A warm, retro-futurist <b>amber</b> theme for <b>Linux Mint Cinnamon (X11)</b>.<br>Amber phosphor on warm black, one palette everywhere: terminal, shell, desktop, and apps.</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-FFB454?style=flat-square" alt="MIT"></a>
  <img src="https://img.shields.io/badge/Linux%20Mint-Cinnamon%20%2F%20X11-FFB454?style=flat-square" alt="Linux Mint Cinnamon / X11">
</p>

<p align="center">
  <img src="docs/screenshots/settings.png" width="49%">
  <img src="docs/screenshots/nemo.png" width="49%">
  <img src="docs/screenshots/ghostty-tabs.png" width="49%">
  <img src="docs/screenshots/editor.png" width="49%">
</p>

## What's themed

- **Terminal & shell:** Ghostty (theme + halo/CRT shaders), zsh + Starship, eza/bat/fd/zoxide/fzf/fastfetch, JetBrainsMono Nerd Font.
- **Cinnamon desktop:** the `Amber` theme (Mint-Y-Dark fork) with a single flat `#16110D` background, amber text/borders/menus/tabs, panel applets (statusline + CRT toggle), a multi-monitor conky HUD, and a rofi launcher.
- **Icons:** `Amber-Icons`, a full monochrome-amber set (Papirus recolored via a single-hue ramp, relief preserved).
- **Consistent everywhere:** context menus, applet popups, GTK apps, cinnamon-settings, and GTK4/libadwaita windows.

## Install

Requires `make`, `stow`, `papirus-icon-theme`, the `Mint-Y-Dark-Sand` base theme, and JetBrainsMono Nerd Font.

```sh
git clone git@github.com:Axel-Ollivier/amber-os.git ~/.dotfiles
cd ~/.dotfiles
make install     # dotfiles + theme + icons, applied
make greeter     # optional amber lock screen (LightDM, needs sudo)
```

Run `make` with no target to list everything: `stow`, `theme`, `icons`, `activate`, `greeter`.

## How it works

The theme and icon set are generated (not committed) and idempotent: every run forks upstream Mint-Y-Dark-Sand / Papirus.

- `theme/warmize.py` maps each neutral or cold gray to a warm amber step of equal luminance, while preserving brand colors and light text.
- `icons/icon-amberize.py` recolors every SVG to a single-hue amber ramp, keeping each icon's relief.

## Layout

Each package mirrors `$HOME` (e.g. `ghostty/.config/ghostty/config` links to `~/.config/ghostty/config`).

- `theme/`, `icons/` : theme and icon generators
- `ghostty/`, `zsh/`, `starship/`, `conky/`, `rofi/`, `gtk/` : stow packages
- `cinnamon/`, `lightdm/` : snapshot/rollback and greeter setup

## License

[MIT](LICENSE)
