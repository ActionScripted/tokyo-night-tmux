#!/usr/bin/env bash
# Generates the complete powerline window-tab string and stores it in
# @tokyo-night-tmux_window_tabs. Called once on plugin load and re-triggered
# by tmux hooks whenever window state changes (focus, create, close, rename,
# activity). status-left consumes it via #{E:@tokyo-night-tmux_window_tabs}.
#
# This is the same approach used by tmux-powerline: a script that sees all
# windows at once can emit correct fg=left_bg,bg=right_bg arrows at every
# boundary without a background-coloured gap cell between tabs.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/themes.sh"

show_arrows="$(tmux show-option -gqv '@tokyo-night-tmux_show_arrows' 2>/dev/null)"
case "${show_arrows,,}" in 1|on|yes|true) ARROWS=1 ;; *) ARROWS=0 ;; esac

window_id_style="$(tmux show-option -gqv '@tokyo-night-tmux_window_id_style' 2>/dev/null)"
window_id_style="${window_id_style:-fsquare}"

BG="${THEME[background]}"
BB="${THEME[bblack]}"
MG="${THEME[magenta]}"
YL="${THEME[yellow]}"
BK="${THEME[black]}"
FG="${THEME[foreground]}"
ARR=$'\xee\x82\xb0'

mapfile -t wlines < <(tmux list-windows -F '#{window_index} #{window_active} #{window_activity_flag} #{window_name}' 2>/dev/null)

if [[ ${#wlines[@]} -eq 0 ]]; then
    tmux set-option -gq @tokyo-night-tmux_window_tabs "#[fg=${FG},bg=${BG},nobold]" 2>/dev/null
    exit 0
fi

out=""
# sl_arrow (status-left) ends on bblack when arrows are on, background when off
(( ARROWS )) && prev_color="$BB" || prev_color="$BG"

for line in "${wlines[@]}"; do
    read -r idx active activity name <<< "$line"

    if [[ "$active" == "1" ]]; then
        cur_color="$MG"
    elif [[ "$activity" == "1" ]]; then
        cur_color="$YL"
    else
        cur_color="$BB"
    fi

    winnum="$("$CURRENT_DIR/custom-number.sh" "$idx" "$window_id_style" 2>/dev/null)"

    # Open a clickable mouse range bound to this window. Without this, the tabs
    # are just text in status-left and clicks can't resolve a window — the
    # default `MouseDown1Status switch-client -t =` binding relies on the
    # range=window range to know which window was clicked. Native
    # window-status-format adds these automatically; a hand-built string must
    # add them by hand. The leading arrow is inside the range so there are no
    # dead zones between tabs.
    out+="#[range=window|${idx}]"

    # Hard separator only where colors actually change — no background gap cell
    if (( ARROWS )) && [[ "$prev_color" != "$cur_color" ]]; then
        out+="#[fg=${prev_color},bg=${cur_color}]${ARR}"
    fi

    if [[ "$active" == "1" ]]; then
        out+="#[fg=${BK},bg=${MG},bold] ${winnum}${name} #[nobold]"
    elif [[ "$activity" == "1" ]]; then
        out+="#[fg=${BK},bg=${YL}] ${winnum}${name} "
    else
        out+="#[fg=${FG},bg=${BB}] ${winnum}${name} "
    fi

    out+="#[norange]"

    prev_color="$cur_color"
done

# Closing arrow: last tab → background
if (( ARROWS )); then
    out+="#[fg=${prev_color},bg=${BG}]${ARR}"
fi
out+="#[fg=${FG},bg=${BG},nobold]"

tmux set-option -gq @tokyo-night-tmux_window_tabs "$out" 2>/dev/null
