#!/usr/bin/env bash
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# title      Tokyo Night                                              +
# version    1.0.0                                                    +
# repository https://github.com/ActionScripted/tokyo-night-tmux       +
# author     ActionScripted                                           +
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_PATH="$CURRENT_DIR/src"

source "$SCRIPTS_PATH/themes.sh"

tmux set -g status-left-length 80
tmux set -g status-right-length 150

tmux set -g mode-style "fg=${THEME[bblack]},bg=${THEME[bblue]}"
tmux set -g prompt-cursor-colour "${THEME[bblack]}"
tmux set -g menu-style "fg=${THEME[foreground]},bg=${THEME[background]}"
tmux set -g menu-selected-style "fg=${THEME[background]},bg=${THEME[blue]}"
tmux set -g menu-border-style "fg=${THEME[blue]}"

tmux set -g message-style "bg=${THEME[bblue]},fg=${THEME[bblack]},bold"
tmux set -g message-command-style "fg=${THEME[bblue]},bg=${THEME[bblack]},bold"
tmux bind : command-prompt -p " ❯"

tmux set -g pane-border-style "fg=${THEME[bblack]}"
tmux set -g pane-active-border-style "fg=${THEME[blue]}"
tmux set -g pane-border-status off

tmux set -g status-style bg="${THEME[background]}"
tmux set -g popup-border-style "fg=${THEME[blue]}"

status_divider_color="${THEME[bblack]}"
status_divider_format="#[fg=${status_divider_color}]#{R:─,#{client_width}}"

tmux_get_var() {
    tmux show -gqv "$1" 2>/dev/null
}

is_enabled() {
    case "${1,,}" in
    1 | on | yes | true)
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

# Powerline arrow helpers (require Nerd Font).
# sep_r LEFT_BG RIGHT_BG  →  right-pointing arrow transitioning between two segment backgrounds.
# sep_l RIGHT_BG LEFT_BG  →  left-pointing arrow (for right-side widgets).
sep_r() { printf '#[fg=%s,bg=%s]\xee\x82\xb0' "$1" "$2"; }
sep_l() { printf '#[fg=%s,bg=%s]\xee\x82\xb2' "$1" "$2"; }

default_window_id_style="fsquare"

prefix_color="$(tmux_get_var '@tokyo-night-tmux_prefix_color')"
show_battery_widget="$(tmux_get_var '@tokyo-night-tmux_show_battery_widget')"
show_datetime="$(tmux_get_var '@tokyo-night-tmux_show_datetime')"
show_git="$(tmux_get_var '@tokyo-night-tmux_show_git')"
show_hostname="$(tmux_get_var '@tokyo-night-tmux_show_hostname')"
show_music="$(tmux_get_var '@tokyo-night-tmux_show_music')"
show_netspeed="$(tmux_get_var '@tokyo-night-tmux_show_netspeed')"
show_path="$(tmux_get_var '@tokyo-night-tmux_show_path')"
show_status_divider="$(tmux_get_var '@tokyo-night-tmux_status_divider')"
show_arrows="$(tmux_get_var '@tokyo-night-tmux_show_arrows')"
show_wbg="$(tmux_get_var '@tokyo-night-tmux_show_wbg')"
window_id_style="$(tmux_get_var '@tokyo-night-tmux_window_id_style')"

window_id_style="${window_id_style:-$default_window_id_style}"

show_arrows="${show_arrows:-0}"
show_battery_widget="${show_battery_widget:-0}"
show_datetime="${show_datetime:-0}"
show_git="${show_git:-0}"
show_hostname="${show_hostname:-0}"
show_music="${show_music:-0}"
show_netspeed="${show_netspeed:-0}"
show_path="${show_path:-0}"
show_status_divider="${show_status_divider:-1}"
show_wbg="${show_wbg:-0}"

# Prefix-active badge colour defaults to red; override with @..._prefix_color.
prefix_bg="${THEME[red]}"
[[ -n "$prefix_color" ]] && prefix_bg="${THEME[$prefix_color]:-$prefix_color}"

# Arrow separators (U+E0B0/U+E0B2, Nerd Font required).
#
# Pill approach: every tab independently transitions to/from the status bar
# background. This avoids the need for any cross-tab color knowledge — in
# particular, activity-flagged tabs (yellow bg) work correctly because the
# inactive arrow uses #{?window_activity_flag,...} to pick the right color at
# tmux render time. The conditional sits inside a #[bg=...] or #[fg=...] value,
# NOT inside a #{?...} as a full #[...] block — that distinction is what the
# comment below the status-left format warns about.
#
# Active:   bg → magenta → bg
# Inactive: bg → #{?activity,yellow,bblack} → bg
open_active=""
close_active=""
open_inactive=""
close_inactive=""
sl_arrow=""
right_cap=""

if is_enabled "$show_arrows"; then
    open_active="#[fg=${THEME[background]},bg=${THEME[magenta]}]"$'\xee\x82\xb0'
    close_active="#[fg=${THEME[magenta]},bg=${THEME[background]}]"$'\xee\x82\xb0'

    open_inactive="#[fg=${THEME[background]},bg=#{?window_activity_flag,${THEME[yellow]},${THEME[bblack]}}]"$'\xee\x82\xb0'
    close_inactive="#[fg=#{?window_activity_flag,${THEME[yellow]},${THEME[bblack]}},bg=${THEME[background]}]"$'\xee\x82\xb0'

    sl_arrow="#[nobold,fg=#{?client_prefix,${prefix_bg},${THEME[blue]}},bg=${THEME[background]}]"$'\xee\x82\xb0'

    # First enabled right-side widget determines the cap color.
    _rc_bg=""
    is_enabled "$show_battery_widget" && _rc_bg="${THEME[yellow]}"
    [[ -z "$_rc_bg" ]] && is_enabled "$show_path"     && _rc_bg="${THEME[blue]}"
    [[ -z "$_rc_bg" ]] && is_enabled "$show_music"    && _rc_bg="${THEME[magenta]}"
    [[ -z "$_rc_bg" ]] && is_enabled "$show_netspeed" && _rc_bg="${THEME[cyan]}"
    [[ -z "$_rc_bg" ]] && { is_enabled "$show_git" || is_enabled "$show_wbg"; } && _rc_bg="${THEME[green]}"
    [[ -z "$_rc_bg" ]] && is_enabled "$show_datetime" && _rc_bg="${THEME[bblack]}"
    [[ -n "$_rc_bg" ]] && right_cap="$(sep_l "${_rc_bg}" "${THEME[background]}")"
fi

window_number="#($SCRIPTS_PATH/custom-number.sh #I $window_id_style)"

cmus_status=""
is_enabled "$show_music" && cmus_status="#($SCRIPTS_PATH/music-tmux-statusbar.sh)"

git_status=""
is_enabled "$show_git" && git_status="#($SCRIPTS_PATH/git-status.sh #{pane_current_path})"

netspeed=""
is_enabled "$show_netspeed" && netspeed="#($SCRIPTS_PATH/netspeed.sh)"

wb_git_status=""
is_enabled "$show_wbg" && wb_git_status="#($SCRIPTS_PATH/wb-git-status.sh #{pane_current_path} &)"

battery_status=""
is_enabled "$show_battery_widget" && battery_status="#($SCRIPTS_PATH/battery-widget.sh)"

current_path=""
is_enabled "$show_path" && current_path="#($SCRIPTS_PATH/path-widget.sh #{pane_current_path})"

date_and_time=""
is_enabled "$show_datetime" && date_and_time="#($SCRIPTS_PATH/datetime-widget.sh)"

hostname=""
is_enabled "$show_hostname" && hostname="#($SCRIPTS_PATH/hostname-widget.sh)"

#+--- Bars LEFT ---+
# Session name
#
# IMPORTANT: keep every `#{?...}` conditional comma-free (it may only resolve to
# a plain color or glyph, never a `#[...]` block). tmux's conditional parser
# miscounts the commas inside a nested `#[fg=...,bg=...]` and leaks the raw style
# text (e.g. a literal "bg=#222436") onto the status line, which also corrupts
# the colors of everything drawn after it. So the `#[...]` blocks live OUTSIDE
# the conditionals and the conditionals only choose the prefix color/glyph.
tmux set -g status-left "#[fg=${THEME[bblack]},bg=#{?client_prefix,${prefix_bg},${THEME[blue]}},bold] #{?client_prefix,󰠠,#[dim]󰤂#[nodim]} #S$hostname ${sl_arrow}#[fg=${THEME[foreground]},bg=${THEME[background]},nobold]"

#+--- Windows ---+
# Pure native formats: tmux evaluates the colours itself per window, so switching
# tabs updates instantly. Conditionals only ever resolve to a plain colour (never
# a `#[...]` block) to avoid tmux's comma-parsing leak.
#   active  -> magenta (purple)   activity -> yellow   otherwise -> bblack
win_bg="#{?window_activity_flag,${THEME[yellow]},${THEME[bblack]}}"
win_fg="#{?window_activity_flag,${THEME[black]},${THEME[foreground]}}"
# Focus (active window)
tmux set -g window-status-current-format "${open_active}#[fg=${THEME[black]},bg=${THEME[magenta]},bold] $window_number#W#{?window_zoomed_flag, 󰍉,} ${close_active}#[fg=${THEME[foreground]},bg=${THEME[background]},nobold]"
# Unfocused — open_inactive/close_inactive use #{?window_activity_flag,...} so
# activity-flagged tabs (yellow bg) get correct arrow colors automatically.
tmux set -g window-status-format "${open_inactive}#[fg=${win_fg},bg=${win_bg}] $window_number#W#{?window_zoomed_flag, 󰍉,} ${close_inactive}#[fg=${THEME[foreground]},bg=${THEME[background]},nobold]"
# tmux's activity/bell window styles default to `reverse`, which would flip the
# explicit fg/bg set above (dark bg + orange fg instead of orange bg + dark fg).
# The format already colours those windows, so neutralise the built-in styles.
tmux set -g window-status-activity-style "default"
tmux set -g window-status-bell-style "default"

#+--- Bars RIGHT ---+
tmux set -g status-right "${right_cap}${battery_status}${current_path}${cmus_status}${netspeed}${git_status}${wb_git_status}${date_and_time}"
tmux set -g window-status-separator ""

status_primary_format="$(tmux_get_var '@tokyo-night-tmux_status_primary_format')"
if [[ -z "$status_primary_format" ]]; then
    status_primary_format="$(tmux show -gv status-format[0] 2>/dev/null)"
    tmux set -gq @tokyo-night-tmux_status_primary_format "$status_primary_format"
fi

if is_enabled "$show_status_divider"; then
    tmux set -g status 2
    tmux set -g status-format[0] "#{?#{==:#{status-position},top},#{E:@tokyo-night-tmux_status_primary_format},$status_divider_format}"
    tmux set -g status-format[1] "#{?#{==:#{status-position},top},$status_divider_format,#{E:@tokyo-night-tmux_status_primary_format}}"
else
    tmux set -g status on
    tmux set -g status-format[0] "#{E:@tokyo-night-tmux_status_primary_format}"
    tmux set -g status-format[1] ""
fi

# Clean up machinery from older versions that drove the tabs through a script,
# a stored option, and refresh hooks (the window tabs are now pure native format).
for _hook in \
    after-select-window \
    after-new-window \
    window-linked \
    window-unlinked \
    window-renamed \
    pane-focus-in \
    alert-activity \
    alert-bell \
    alert-silence; do
    tmux set-hook -gu "${_hook}[99]" 2>/dev/null
done
