#!/usr/bin/env bash

SELECTED_THEME="$(tmux show-option -gqv @tokyo-night-tmux_theme)"
TRANSPARENT_THEME="$(tmux show-option -gqv @tokyo-night-tmux_transparent)"

case $SELECTED_THEME in
"moon")
  declare -A THEME=(
    ["background"]="#222436"
    ["foreground"]="#c8d3f5"
    ["black"]="#1b1d2b"
    ["blue"]="#82aaff"
    ["cyan"]="#86e1fc"
    ["green"]="#c3e88d"
    ["magenta"]="#c099ff"
    ["red"]="#ff757f"
    ["white"]="#828bb8"
    ["yellow"]="#ffc777"

    ["bblack"]="#444a73"
    ["bblue"]="#9ab8ff"
    ["bcyan"]="#b2ebff"
    ["bgreen"]="#c7fb6d"
    ["bmagenta"]="#caabff"
    ["bred"]="#ff8d94"
    ["bwhite"]="#c8d3f5"
    ["byellow"]="#ffd8ab"
  )
  ;;
"storm")
  declare -A THEME=(
    ["background"]="#24283b"
    ["foreground"]="#c0caf5"
    ["black"]="#1d202f"
    ["blue"]="#7aa2f7"
    ["cyan"]="#7dcfff"
    ["green"]="#9ece6a"
    ["magenta"]="#bb9af7"
    ["red"]="#f7768e"
    ["white"]="#a9b1d6"
    ["yellow"]="#e0af68"

    ["bblack"]="#414868"
    ["bblue"]="#8db0ff"
    ["bcyan"]="#a4daff"
    ["bgreen"]="#9fe044"
    ["bmagenta"]="#c7a9ff"
    ["bred"]="#ff899d"
    ["bwhite"]="#c0caf5"
    ["byellow"]="#faba4a"
  )
  ;;

"day")
  declare -A THEME=(
    ["background"]="#e1e2e7"
    ["foreground"]="#3760bf"
    ["black"]="#b4b5b9"
    ["blue"]="#2e7de9"
    ["cyan"]="#007197"
    ["green"]="#587539"
    ["magenta"]="#9854f1"
    ["red"]="#f52a65"
    ["white"]="#6172b0"
    ["yellow"]="#8c6c3e"

    ["bblack"]="#a1a6c5"
    ["bblue"]="#358aff"
    ["bcyan"]="#007ea8"
    ["bgreen"]="#5c8524"
    ["bmagenta"]="#a463ff"
    ["bred"]="#ff4774"
    ["bwhite"]="#3760bf"
    ["byellow"]="#a27629"
  )
  ;;

*)
  # Default to night theme
  declare -A THEME=(
    ["background"]="#1a1b26"
    ["foreground"]="#c0caf5"
    ["black"]="#15161e"
    ["blue"]="#7aa2f7"
    ["cyan"]="#7dcfff"
    ["green"]="#9ece6a"
    ["magenta"]="#bb9af7"
    ["red"]="#f7768e"
    ["white"]="#a9b1d6"
    ["yellow"]="#e0af68"

    ["bblack"]="#414868"
    ["bblue"]="#8db0ff"
    ["bcyan"]="#a4daff"
    ["bgreen"]="#9fe044"
    ["bmagenta"]="#c7a9ff"
    ["bred"]="#ff899d"
    ["bwhite"]="#c0caf5"
    ["byellow"]="#faba4a"
  )
  ;;
esac

# Override background with "default" if transparent theme is enabled
if [ "${TRANSPARENT_THEME}" == 1 ]; then
  THEME["background"]="default"
fi

THEME['ghgreen']="#3fb950"
THEME['ghmagenta']="#A371F7"
THEME['ghred']="#d73a4a"
THEME['ghyellow']="#d29922"
