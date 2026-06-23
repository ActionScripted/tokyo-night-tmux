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

RESET="#[fg=${THEME[foreground]},bg=${THEME[background]},nobold,noitalics,nounderscore,nodim]"
SEPARATOR=""

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

default_window_id_style="digital"
default_pane_id_style="hsquare"
default_zoom_id_style="dsquare"

default_terminal_icon=""
default_active_terminal_icon=""

active_terminal_icon="$(tmux_get_var '@tokyo-night-tmux_active_terminal_icon')"
pane_id_style="$(tmux_get_var '@tokyo-night-tmux_pane_id_style')"
prefix_color="$(tmux_get_var '@tokyo-night-tmux_prefix_color')"
show_battery_widget="$(tmux_get_var '@tokyo-night-tmux_show_battery_widget')"
show_datetime="$(tmux_get_var '@tokyo-night-tmux_show_datetime')"
show_git="$(tmux_get_var '@tokyo-night-tmux_show_git')"
show_hostname="$(tmux_get_var '@tokyo-night-tmux_show_hostname')"
show_music="$(tmux_get_var '@tokyo-night-tmux_show_music')"
show_netspeed="$(tmux_get_var '@tokyo-night-tmux_show_netspeed')"
show_path="$(tmux_get_var '@tokyo-night-tmux_show_path')"
show_status_divider="$(tmux_get_var '@tokyo-night-tmux_status_divider')"
show_wbg="$(tmux_get_var '@tokyo-night-tmux_show_wbg')"
terminal_icon="$(tmux_get_var '@tokyo-night-tmux_terminal_icon')"
window_id_style="$(tmux_get_var '@tokyo-night-tmux_window_id_style')"
zoom_id_style="$(tmux_get_var '@tokyo-night-tmux_zoom_id_style')"

active_terminal_icon="${active_terminal_icon:-$default_active_terminal_icon}"
pane_id_style="${pane_id_style:-$default_pane_id_style}"
terminal_icon="${terminal_icon:-$default_terminal_icon}"
window_id_style="${window_id_style:-$default_window_id_style}"
zoom_id_style="${zoom_id_style:-$default_zoom_id_style}"

show_battery_widget="${show_battery_widget:-0}"
show_datetime="${show_datetime:-0}"
show_git="${show_git:-0}"
show_hostname="${show_hostname:-0}"
show_music="${show_music:-0}"
show_netspeed="${show_netspeed:-0}"
show_path="${show_path:-0}"
show_status_divider="${show_status_divider:-1}"
show_wbg="${show_wbg:-0}"

prefix_bg="${THEME[blue]}"
[[ -n "$prefix_color" ]] && prefix_bg="${THEME[$prefix_color]:-$prefix_color}"

[[ "$terminal_icon" == "none" ]] && terminal_icon=""
[[ "$active_terminal_icon" == "none" ]] && active_terminal_icon=""

SSH_ICON="󰣀"

if [[ -n "$terminal_icon" ]]; then
    terminal_icon_status="#{?#{==:#{pane_current_command},ssh},$SSH_ICON , $terminal_icon }"
else
    terminal_icon_status=""
fi

if [[ -n "$active_terminal_icon" ]]; then
    active_terminal_icon_status="#{?#{==:#{pane_current_command},ssh},$SSH_ICON , $active_terminal_icon }"
else
    active_terminal_icon_status=""
fi

custom_pane="#($SCRIPTS_PATH/custom-number.sh #P $pane_id_style)"
window_number="#($SCRIPTS_PATH/custom-number.sh #I $window_id_style)"
zoom_number="#($SCRIPTS_PATH/custom-number.sh #P $zoom_id_style)"
window_tab="#($SCRIPTS_PATH/window-tab.sh #I \"$terminal_icon\" \"$active_terminal_icon\" \"$window_id_style\" \"$pane_id_style\" \"$zoom_id_style\")"

if [[ "$pane_id_style" == "hide" ]]; then
    custom_pane_expr=""
else
    custom_pane_expr=" $custom_pane"
fi

if [[ "$zoom_id_style" == "hide" ]]; then
    zoom_expr=""
else
    zoom_expr=" $zoom_number"
fi

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
tmux set -g status-left "#{?client_prefix,#[fg=${THEME[bblack]},bg=${prefix_bg},bold] #{?client_prefix,󰠠 ,#[dim]󰤂 }#[bold,nodim]#S$hostname #[fg=${prefix_bg},bg=${THEME[background]},nobold]$SEPARATOR,#[fg=${THEME[bblack]},bg=${THEME[blue]},bold] #{?client_prefix,󰠠 ,#[dim]󰤂 }#[bold,nodim]#S$hostname #[fg=${THEME[blue]},bg=${THEME[background]},nobold]$SEPARATOR}"

#+--- Windows ---+
# Focus
tmux set -g window-status-current-format "$window_tab"
# Unfocused
tmux set -g window-status-format "$window_tab"

#+--- Bars RIGHT ---+
tmux set -g status-right "$battery_status$current_path$cmus_status$netspeed$git_status$wb_git_status$date_and_time"
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
