# Customization

[← Back to README](../README.md) · [Installation →](installation.md) · [Themes →](themes.md) · [Widgets →](widgets.md)

---

## Window number style

Window tabs are numbered with stylized glyphs. Pick the style:

```bash
set -g @tokyo-night-tmux_window_id_style fsquare
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

> **Default:** `window_id_style = fsquare`

---

## Window tab colors

Each tab shows its number and name as a colored block. Colors are driven by window state:

| State | Color |
|---|---|
| Active window | Magenta (purple) |
| Window with activity | Yellow |
| Other windows | Muted |

Activity highlighting requires tmux's activity monitoring:

```bash
set -g monitor-activity on
```

---

## Prefix highlight

When the tmux prefix key is active, the session name badge changes its icon to `󰠠` and its background turns red. Change the color with a theme color name:

```bash
set -g @tokyo-night-tmux_prefix_color blue
```

> **Default:** `prefix_color = red`

Available names: `red`, `blue`, `green`, `cyan`, `magenta`, `yellow`, `white`, `black`, `bred`, `bblue`, `bgreen`, `bcyan`, `bmagenta`, `byellow`. A raw hex value (e.g. `#ff0000`) also works.

---

## Applying changes

After editing `~/.tmux.conf`, reload your config:

```bash
tmux source ~/.tmux.conf
```

For changes to widget options (battery, path, etc.), a full tmux restart may be needed.
