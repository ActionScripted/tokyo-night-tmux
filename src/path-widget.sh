#!/usr/bin/env bash

# Imports
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
. "${ROOT_DIR}/lib/coreutils-compat.sh"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/themes.sh"

PATH_FORMAT=$(tmux show-option -gv @tokyo-night-tmux_path_format 2>/dev/null) # full | relative
SEGMENT_BG="${THEME[blue]}"
RESET="#[fg=${THEME[foreground]},bg=${SEGMENT_BG},nobold,noitalics,nounderscore,nodim]"

current_path="${1}"
default_path_format="relative"
PATH_FORMAT="${PATH_FORMAT:-$default_path_format}"

# check user requested format
if [[ ${PATH_FORMAT} == "relative" ]]; then
  current_path="$(echo ${current_path} | sed 's#'"$HOME"'#~#g')"
fi

echo "#[fg=${THEME[yellow]},bg=${SEGMENT_BG}]#[fg=${THEME[bblack]},bg=${SEGMENT_BG}]  ${current_path} "
