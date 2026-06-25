# Plan: Powerline Arrow Separators

## How the arrow effect works

A single Unicode character whose fg/bg are set to the backgrounds of the two
adjacent segments creates the filled-triangle illusion:

```
[seg A bg]  [seg B bg]
           ↑
     fg=segA_bg, bg=segB_bg
```

Character (requires Nerd Font / Powerline-patched font): `` U+E0B0

## The neighbor-tab problem — and how tmux-powerline solves it

`window-status-format` is evaluated per-window with no access to neighbor state.
tmux-powerline's solution: **put all transition arrows on the ACTIVE tab, not the
inactive tabs.**

Since all inactive tabs always share the same background color, the active tab
can hard-code `fg=inactive_bg` without querying any neighbor. No cross-window
knowledge needed — and no script hooks required.

Trace through `[inactive][active][inactive]`:

```
[bblack content + reset]                           ← inactive tab
[fg=bblack,bg=magenta  ▶  fg=black content  ▶  fg=magenta,bg=bblack  reset]  ← active
[bblack content + reset]                           ← inactive tab
```

Each tab still ends with a background reset. Because `window-status-separator`
is `""`, no characters are output between the end of one tab and the start of
the next, so the intermediate resets have no visual effect. The arrow character
itself carries the color — the transition is seamless.

Result:
```
 bblack tab1  ◀bblack on magenta▶  magenta ACTIVE  ◀magenta on bblack▶  bblack tab3 
```

## Helper

```bash
# sep FROM_BG TO_BG  →  tmux format string for a right-pointing arrow
sep() { printf '#[fg=%s,bg=%s]' "$1" "$2"; }
```

The rule is always: fg = leaving segment's bg, bg = arriving segment's bg.

## What to change

### 1. New tmux option

```
@tokyo-night-tmux_show_arrows  0|1  (default: 0)
```

Read alongside the other feature flags. Build all arrow strings inside
`if is_enabled "$show_arrows"` — leave them empty otherwise so the format
string splices are unconditional no-ops.

### 2. `status-left` — trailing arrow after the session block

Session block has two possible backgrounds: `THEME[blue]` normally, or
`prefix_bg` when the prefix is active. The existing `#{?client_prefix,...}`
conditional already handles that; the arrow just needs to follow it, using
whichever bg was active. Build two versions and select in bash (the existing
comment at tokyo-night.tmux:116 warns against `#[...]` blocks inside tmux
conditionals):

```bash
# Normal: blue block → background
arrow_l_normal="$(sep "${THEME[blue]}" "${THEME[background]}")"
# Prefix-active: prefix_bg block → background
arrow_l_prefix="$(sep "${prefix_bg}" "${THEME[background]}")"
```

Assemble two full `status-left` strings (normal and prefix) and use the tmux
conditional to choose between them — the `#[...]` blocks live outside the
`#{?...}` in both strings.

### 3. Window tabs — active tab owns the arrows

**Active window (magenta bg):**
```bash
open_active="$(sep "${THEME[bblack]}" "${THEME[magenta]}")"   # bblack → magenta
close_active="$(sep "${THEME[magenta]}" "${THEME[bblack]}")"  # magenta → bblack
```

Splice `open_active` before the first `#[fg=...,bg=magenta,...]` and
`close_active` before the final reset in `window-status-current-format`.

**Inactive window (bblack bg):**  
No arrows. Leave `window-status-format` structurally unchanged — just the
content block followed by the background reset.

Activity-flag tabs (win_bg switches to yellow) are intentionally not handled:
the active tab's arrows will show bblack on one side, not yellow. This is
acceptable and matches tmux-powerline's behavior with its own edge cases.

### 4. `status-right` — leading arrow before the first widget

All right-side widgets use `THEME[bblack]` as their background. Prepend a
single left-pointing cap (`#[fg=...,bg=...]` + U+E0B2) to the first enabled
widget:

```bash
arrow_r_cap="$(sep "${THEME[bblack]}" "${THEME[background]}")"
# U+E0B2 ← character appended after this
```

## Implementation steps

1. Read `show_arrows` option, default `0`.
2. Define the `sep` helper.
3. Build `arrow_l_normal`, `arrow_l_prefix`, `open_active`, `close_active`,
   `arrow_r_cap` (all empty strings when arrows disabled).
4. Assemble two `status-left` strings (normal / prefix) and splice in the
   appropriate arrow at the end of each; select between them with
   `#{?client_prefix,...}`.
5. Splice `open_active` + `close_active` into `window-status-current-format`.
6. Leave `window-status-format` arrow-free (inactive tabs need no changes).
7. Prepend `arrow_r_cap` + U+E0B2 to the first non-empty right-side widget.

## Scope / non-goals

- Nerd Font required; no ASCII fallback (add a comment noting this).
- Activity-flag yellow → active arrow transition not handled (same tradeoff
  tmux-powerline makes).
- No per-widget arrow colors on the right; a single leading cap is sufficient.
