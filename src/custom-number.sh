#!/usr/bin/env bash

# Imports
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
. "${ROOT_DIR}/lib/coreutils-compat.sh"

format_hide=""
format_none="0123456789"
format_digital="🯰🯱🯲🯳🯴🯵🯶🯷🯸🯹"
format_fsquare="󰎡󰎤󰎧󰎪󰎭󰎱󰎳󰎶󰎹󰎼"
format_hsquare="󰎣󰎦󰎩󰎬󰎮󰎰󰎵󰎸󰎻󰎾"
format_dsquare="󰎢󰎥󰎨󰎫󰎲󰎯󰎴󰎷󰎺󰎽"
format_roman=" 󱂈󱂉󱂊󱂋󱂌󱂍󱂎󱂏󱂐"
format_super="⁰¹²³⁴⁵⁶⁷⁸⁹"
format_sub="₀₁₂₃₄₅₆₇₈₉"

# Defined as a function so callers (e.g. window-tab.sh) can source this file and
# format numbers in-process instead of paying a fork+exec per window.
# custom_number ID [FORMAT] [OUTVAR]
# With OUTVAR the result is assigned to that variable (no subshell); otherwise it
# is printed. Callers in hot paths pass OUTVAR to avoid a fork per number.
custom_number() {
  local ID="$1"
  local FORMAT="${2:-none}"
  local outvar="$3"
  local fmtvar="format_${FORMAT}"
  # Indirect expansion preserves any leading whitespace in the format string.
  local format="${!fmtvar}"
  local i DIGIT result=""

  if [ "$FORMAT" != "hide" ]; then
    [ -z "$format" ] && format="$format_none"
    # If format is roman numerals (-r), only handle IDs of 1 digit
    if [ "$FORMAT" = "roman" ] && [ "${#ID}" -gt 1 ]; then
      result="$ID "
    else
      for ((i = 0; i < ${#ID}; i++)); do
        DIGIT=${ID:i:1}
        result+="${format:DIGIT:1} "
      done
    fi
  fi

  if [ -n "$outvar" ]; then
    printf -v "$outvar" '%s' "$result"
  else
    printf '%s' "$result"
  fi
}

# Keep the original CLI behaviour when executed directly.
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  custom_number "$1" "${2:-none}"
fi
