#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/themes.sh"

window_index="$1"
terminal_icon="$2"
active_terminal_icon="$3"
window_id_style="$4"
pane_id_style="$5"
zoom_id_style="$6"

SEPARATOR=""
SSH_ICON="󰣀"

tab_bg() {
  local active="$1"
  local activity="$2"
  local bell="$3"
  local last="$4"

  if [[ "$active" == "1" ]]; then
    printf '%s\n' "${THEME[magenta]}"
  elif [[ "$bell" == "1" ]]; then
    printf '%s\n' "${THEME[red]}"
  elif [[ "$activity" == "1" ]]; then
    printf '%s\n' "${THEME[cyan]}"
  elif [[ "$last" == "1" ]]; then
    printf '%s\n' "${THEME[yellow]}"
  else
    printf '%s\n' "${THEME[bblack]}"
  fi
}

tab_fg() {
  local active="$1"
  local activity="$2"
  local bell="$3"
  local last="$4"

  if [[ "$active" == "1" || "$activity" == "1" || "$bell" == "1" || "$last" == "1" ]]; then
    printf '%s\n' "${THEME[black]}"
  else
    printf '%s\n' "${THEME[foreground]}"
  fi
}

IFS='|' read -r \
  window_name \
  window_active \
  window_activity_flag \
  window_bell_flag \
  window_last_flag \
  pane_current_command \
  pane_index \
  window_zoomed_flag \
  window_start_flag \
  window_end_flag < <(
  tmux display-message -pt ":${window_index}" -F '#{window_name}|#{window_active}|#{window_activity_flag}|#{window_bell_flag}|#{window_last_flag}|#{pane_current_command}|#{pane_index}|#{window_zoomed_flag}|#{window_start_flag}|#{window_end_flag}'
)

current_bg="$(tab_bg "$window_active" "$window_activity_flag" "$window_bell_flag" "$window_last_flag")"
current_fg="$(tab_fg "$window_active" "$window_activity_flag" "$window_bell_flag" "$window_last_flag")"
next_bg="${THEME[background]}"

found_current=0
while IFS='|' read -r listed_index listed_active listed_activity listed_bell listed_last; do
  if [[ "$found_current" == "1" ]]; then
    next_bg="$(tab_bg "$listed_active" "$listed_activity" "$listed_bell" "$listed_last")"
    break
  fi

  if [[ "$listed_index" == "$window_index" ]]; then
    found_current=1
  fi
done < <(tmux list-windows -F '#{window_index}|#{window_active}|#{window_activity_flag}|#{window_bell_flag}|#{window_last_flag}')

window_number="$($CURRENT_DIR/custom-number.sh "$window_index" "$window_id_style")"

pane_expr=""
if [[ "$window_zoomed_flag" == "1" ]]; then
  if [[ "$zoom_id_style" != "hide" ]]; then
    pane_expr=" $($CURRENT_DIR/custom-number.sh "$pane_index" "$zoom_id_style")"
  fi
elif [[ "$pane_id_style" != "hide" ]]; then
  pane_expr=" $($CURRENT_DIR/custom-number.sh "$pane_index" "$pane_id_style")"
fi

tab_icon=""
if [[ "$pane_current_command" == "ssh" ]]; then
  tab_icon="$SSH_ICON "
elif [[ "$window_active" == "1" ]]; then
  [[ -n "$active_terminal_icon" ]] && tab_icon="$active_terminal_icon "
else
  [[ -n "$terminal_icon" ]] && tab_icon="$terminal_icon "
fi

last_marker=""
if [[ "$window_last_flag" == "1" && "$window_active" != "1" ]]; then
  last_marker=" 󰁯"
fi

style_flags="nobold,nodim"
if [[ "$window_active" == "1" ]]; then
  style_flags="bold,nodim"
elif [[ "$window_activity_flag" != "1" && "$window_bell_flag" != "1" && "$window_last_flag" != "1" ]]; then
  style_flags="nobold,dim"
fi

leading=""
if [[ "$window_start_flag" == "1" ]]; then
  leading="#[fg=${THEME[background]},bg=${current_bg}]${SEPARATOR}"
fi

printf '%s#[fg=%s,bg=%s,%s] %s%s%s%s#[fg=%s,bg=%s]%s' \
  "$leading" \
  "$current_fg" "$current_bg" "$style_flags" \
  "$tab_icon" "$window_number" "$window_name" "$pane_expr$last_marker " \
  "$current_bg" "$next_bg" "$SEPARATOR"
