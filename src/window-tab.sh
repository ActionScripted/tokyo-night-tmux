#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/themes.sh"

terminal_icon="$1"
active_terminal_icon="$2"
window_id_style="$3"
pane_id_style="$4"
zoom_id_style="$5"

SEPARATOR=""
SSH_ICON="󰣀"

tab_bg() {
  local active="$1"
  local activity="$2"
  local bell="$3"
  local last="$4"

  if [[ "$active" == "1" ]]; then
    printf '%s' "${THEME[magenta]}"
  elif [[ "$bell" == "1" ]]; then
    printf '%s' "${THEME[red]}"
  elif [[ "$activity" == "1" ]]; then
    printf '%s' "${THEME[cyan]}"
  elif [[ "$last" == "1" ]]; then
    printf '%s' "${THEME[yellow]}"
  else
    printf '%s' "${THEME[bblack]}"
  fi
}

tab_fg() {
  local active="$1"
  local activity="$2"
  local bell="$3"
  local last="$4"

  if [[ "$active" == "1" || "$activity" == "1" || "$bell" == "1" || "$last" == "1" ]]; then
    printf '%s' "${THEME[black]}"
  else
    printf '%s' "${THEME[foreground]}"
  fi
}

# Render the whole window strip in a single pass.
#
# Each tab's trailing separator (the powerline arrow) is coloured fg=this-tab,
# bg=next-tab so adjacent tabs connect seamlessly. That makes a tab's separator
# depend on its NEIGHBOUR's colour. When every tab was rendered as its own #()
# job, tmux only re-ran a tab's job when that tab's own state changed — not when
# its neighbour changed — so opening/switching windows left separators showing
# stale neighbour colours. Reading every window from one list-windows snapshot
# here keeps all the colours mutually consistent on every redraw.
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
[[ "$count" -eq 0 ]] && exit 0

# Pre-compute every tab's background colour so neighbour lookups are exact.
bgs=()
for ((i = 0; i < count; i++)); do
  bgs+=("$(tab_bg "${actives[i]}" "${activities[i]}" "${bells[i]}" "${lasts[i]}")")
done

out=""
for ((i = 0; i < count; i++)); do
  active="${actives[i]}"
  activity="${activities[i]}"
  bell="${bells[i]}"
  last="${lasts[i]}"

  current_bg="${bgs[i]}"
  current_fg="$(tab_fg "$active" "$activity" "$bell" "$last")"
  if ((i + 1 < count)); then
    next_bg="${bgs[i + 1]}"
  else
    next_bg="${THEME[background]}"
  fi

  window_number="$($CURRENT_DIR/custom-number.sh "${indexes[i]}" "$window_id_style")"

  pane_expr=""
  if [[ "${zooms[i]}" == "1" ]]; then
    if [[ "$zoom_id_style" != "hide" ]]; then
      pane_expr=" $($CURRENT_DIR/custom-number.sh "${panes[i]}" "$zoom_id_style")"
    fi
  elif [[ "$pane_id_style" != "hide" ]]; then
    pane_expr=" $($CURRENT_DIR/custom-number.sh "${panes[i]}" "$pane_id_style")"
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
    last_marker=" 󰁯"
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

  out+="#[range=window|${indexes[i]}]"
  out+="$(printf '%s#[fg=%s,bg=%s,%s] %s%s%s%s#[fg=%s,bg=%s]%s' \
    "$leading" \
    "$current_fg" "$current_bg" "$style_flags" \
    "$tab_icon" "$window_number" "${names[i]}" "$pane_expr$last_marker " \
    "$current_bg" "$next_bg" "$SEPARATOR")"
done

printf '%s#[norange]' "$out"
