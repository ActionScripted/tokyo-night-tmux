#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/themes.sh"
# Sourced for custom_number(): formatting in-process avoids a fork+exec per
# window, which keeps this script fast enough to run on every refresh hook.
source "$CURRENT_DIR/custom-number.sh"

# Glyphs are written with \u escapes so they survive editors/tools that mangle
# raw private-use codepoints.
SEPARATOR=$'\ue0b0'      #
SSH_ICON=$'\U000f08c0'   # 󰣀
LAST_MARKER=$'\U000f006f' # 󰁯

# Config is read from a single packed option so the activity/selection hooks can
# invoke this script with no arguments.
IFS='|' read -r terminal_icon active_terminal_icon window_id_style pane_id_style zoom_id_style \
  < <(tmux show -gqv @tokyo-night-tmux_tab_opts)

STRIP_OPTION="@tokyo-night-tmux_window_strip"

# These assign to globals (TAB_BG / TAB_FG) instead of printing so the render
# loop can call them without a subshell per window.
tab_bg() {
  local active="$1" activity="$2" bell="$3" last="$4"
  if [[ "$active" == "1" ]]; then
    TAB_BG="${THEME[magenta]}"
  elif [[ "$bell" == "1" ]]; then
    TAB_BG="${THEME[red]}"
  elif [[ "$activity" == "1" ]]; then
    TAB_BG="${THEME[cyan]}"
  elif [[ "$last" == "1" ]]; then
    TAB_BG="${THEME[yellow]}"
  else
    TAB_BG="${THEME[bblack]}"
  fi
}

tab_fg() {
  local active="$1" activity="$2" bell="$3" last="$4"
  if [[ "$active" == "1" || "$activity" == "1" || "$bell" == "1" || "$last" == "1" ]]; then
    TAB_FG="${THEME[black]}"
  else
    TAB_FG="${THEME[foreground]}"
  fi
}

# Render the whole window strip in a single pass and store it in a tmux option.
#
# The strip is *displayed* by reading that option (#{@...}) — an instant
# substitution — rather than by a #() job. tmux only re-runs #() jobs on its
# throttled status-redraw schedule, which left the active/last/activity highlight
# visibly lagging (or stuck on the wrong tab) when switching windows. Instead the
# selection/activity hooks run this script (in the background, to avoid blocking
# the server it then calls back into); it rewrites the option and forces a redraw,
# so the strip updates within a few ms of the event. Reading every window from one
# list-windows snapshot also keeps each separator's neighbour colour consistent.
indexes=()
names=()
actives=()
activities=()
bells=()
lasts=()
zooms=()
cmds=()
panes=()

while IFS='|' read -r w_index w_name w_active w_activity w_bell w_last w_zoom p_cmd p_index; do
  indexes+=("$w_index")
  names+=("$w_name")
  actives+=("$w_active")
  activities+=("$w_activity")
  bells+=("$w_bell")
  lasts+=("$w_last")
  zooms+=("$w_zoom")
  cmds+=("$p_cmd")
  panes+=("$p_index")
done < <(
  tmux list-windows -F '#{window_index}|#{window_name}|#{window_active}|#{window_activity_flag}|#{window_bell_flag}|#{window_last_flag}|#{window_zoomed_flag}|#{pane_current_command}|#{pane_index}'
)

count="${#indexes[@]}"
if [[ "$count" -eq 0 ]]; then
  tmux set -gq "$STRIP_OPTION" ""
  exit 0
fi

# Pre-compute every tab's background colour so neighbour lookups are exact.
bgs=()
for ((i = 0; i < count; i++)); do
  tab_bg "${actives[i]}" "${activities[i]}" "${bells[i]}" "${lasts[i]}"
  bgs+=("$TAB_BG")
done

out=""
for ((i = 0; i < count; i++)); do
  active="${actives[i]}"
  activity="${activities[i]}"
  bell="${bells[i]}"
  last="${lasts[i]}"

  current_bg="${bgs[i]}"
  tab_fg "$active" "$activity" "$bell" "$last"
  current_fg="$TAB_FG"
  if ((i + 1 < count)); then
    next_bg="${bgs[i + 1]}"
  else
    next_bg="${THEME[background]}"
  fi

  custom_number "${indexes[i]}" "$window_id_style" window_number

  pane_expr=""
  if [[ "${zooms[i]}" == "1" ]]; then
    if [[ "$zoom_id_style" != "hide" ]]; then
      custom_number "${panes[i]}" "$zoom_id_style" pane_num
      pane_expr=" $pane_num"
    fi
  elif [[ "$pane_id_style" != "hide" ]]; then
    custom_number "${panes[i]}" "$pane_id_style" pane_num
    pane_expr=" $pane_num"
  fi

  tab_icon=""
  if [[ "${cmds[i]}" == "ssh" ]]; then
    tab_icon="$SSH_ICON "
  elif [[ "$active" == "1" ]]; then
    [[ -n "$active_terminal_icon" ]] && tab_icon="$active_terminal_icon "
  else
    [[ -n "$terminal_icon" ]] && tab_icon="$terminal_icon "
  fi

  last_marker=""
  if [[ "$last" == "1" && "$active" != "1" ]]; then
    last_marker=" $LAST_MARKER"
  fi

  style_flags="nobold,nodim"
  if [[ "$active" == "1" ]]; then
    style_flags="bold,nodim"
  elif [[ "$activity" != "1" && "$bell" != "1" && "$last" != "1" ]]; then
    style_flags="nobold,dim"
  fi

  leading=""
  if ((i == 0)); then
    leading="#[fg=${THEME[background]},bg=${current_bg}]${SEPARATOR}"
  fi

  printf -v seg '%s#[fg=%s,bg=%s,%s] %s%s%s%s#[fg=%s,bg=%s]%s' \
    "$leading" \
    "$current_fg" "$current_bg" "$style_flags" \
    "$tab_icon" "$window_number" "${names[i]}" "$pane_expr$last_marker " \
    "$current_bg" "$next_bg" "$SEPARATOR"
  out+="#[range=window|${indexes[i]}]$seg"
done
out+="#[norange]"

tmux set -gq "$STRIP_OPTION" "$out"
# Repaint now that the strip is up to date. The refresh hooks run this script in
# the background, so this is what makes the new strip actually appear promptly.
tmux refresh-client -S 2>/dev/null
