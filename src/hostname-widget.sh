#!/usr/bin/env bash

# Imports
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
. "${ROOT_DIR}/lib/coreutils-compat.sh"

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $CURRENT_DIR/themes.sh

if command -v hostnamectl >/dev/null 2>&1; then
  hostname=$(hostnamectl hostname)
elif command -v scutil >/dev/null 2>&1; then
  hostname=$(scutil --get LocalHostName)
elif command -v hostname >/dev/null 2>&1; then
  hostname=$(hostname)
else
  hostname="unknown-host"
fi
ACCENT_COLOR="${THEME[black]}"

echo "#[nodim,fg=$ACCENT_COLOR]@${hostname}"
