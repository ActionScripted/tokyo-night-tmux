# Customization

[← Back to README](../README.md) · [Installation →](installation.md) · [Themes →](themes.md) · [Widgets →](widgets.md)

---

## Number styles

Tokyo Night Tmux uses stylized numbers for window IDs, pane IDs, and the zoom indicator. Each can be configured independently.

```bash
set -g @tokyo-night-tmux_window_id_style digital   # window tab numbers
set -g @tokyo-night-tmux_pane_id_style hsquare     # pane number shown in status bar
set -g @tokyo-night-tmux_zoom_id_style dsquare     # pane number shown when zoomed
```

### Available styles

| Style | Characters | Notes |
|---|---|---|
| `none` | `0 1 2 3 …` | Default system font |
| `digital` | `🯰 🯱 🯲 🯳 …` | 7-segment display - requires Unicode support |
| `roman` | `󱂈 󱂉 󱂊 …` | Roman numerals — requires Nerd Fonts |
| `fsquare` | `󰎡 󰎤 󰎧 …` | Filled square — requires Nerd Fonts |
| `hsquare` | `󰎣 󰎦 󰎩 …` | Hollow square — requires Nerd Fonts |
| `dsquare` | `󰎢 󰎥 󰎨 …` | Hollow double square — requires Nerd Fonts |
| `super` | `⁰ ¹ ² ³ …` | Superscript symbols |
| `sub` | `₀ ₁ ₂ ₃ …` | Subscript symbols |
| `hide` | *(hidden)* | Number is not shown |

> **Default values:** `window_id_style = digital`, `pane_id_style = hsquare`, `zoom_id_style = dsquare`

---

## Window styles

### Terminal icons

Customize the icon shown on inactive and active window tabs:

```bash
set -g @tokyo-night-tmux_terminal_icon        # icon for inactive windows (default: )
set -g @tokyo-night-tmux_active_terminal_icon  # icon for the active window (default: )
```

Any Nerd Fonts glyph can be used. Copy the glyph character directly into your config. Set to `none` to hide the icon entirely:

```bash
set -g @tokyo-night-tmux_terminal_icon none
set -g @tokyo-night-tmux_active_terminal_icon none
```

### Tidy icons

By default, a space is added between the icon and the window name for readability. Disable it for a more compact look:

```bash
set -g @tokyo-night-tmux_window_tidy_icons 1   # 1 = no extra space | 0 = add space (default)
```

---

## SSH indicator

Windows running an active `ssh` session automatically show the `󰣀` icon instead of the default terminal icon. This is built-in and requires no configuration.

---

## Prefix highlight

When the tmux prefix key is active, the session name badge changes its icon to `󰠠`. By default the background color stays the same. To also change the background color, set a theme color name:

```bash
set -g @tokyo-night-tmux_prefix_color red
```

Available names: `red`, `blue`, `green`, `cyan`, `magenta`, `yellow`, `white`, `black`, `bred`, `bblue`, `bgreen`, `bcyan`, `bmagenta`, `byellow`. A raw hex value (e.g. `#ff0000`) also works.

---

## Zoom indicator

When a pane is zoomed (`prefix` + `z`), the pane number in the status bar is rendered using the `zoom_id_style` instead of the normal `pane_id_style`. Configure it with:

```bash
set -g @tokyo-night-tmux_zoom_id_style dsquare
```

---

## Applying changes

After editing `~/.tmux.conf`, reload your config:

```bash
tmux source ~/.tmux.conf
```

For changes to widget options (battery, path, etc.), a full tmux restart may be needed.
