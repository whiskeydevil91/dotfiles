#!/usr/bin/env bash

# ------------------------------------------------------------
# show-keybindings.sh
# Lists every Hyprland keybinding that has a description,
# read live from `hyprctl binds -j`.
# ------------------------------------------------------------

set -euo pipefail

if ! command -v jq &>/dev/null; then
    notify-send "Keybindings" "jq is not installed"
    exit 1
fi

# modmask bits → readable modifier names
LIST=$(hyprctl binds -j | jq -r '
  def mods:
    [ (if . / 64 | floor % 2 == 1 then "Super" else empty end),
      (if . / 4  | floor % 2 == 1 then "Ctrl"  else empty end),
      (if . / 8  | floor % 2 == 1 then "Alt"   else empty end),
      (if .      | floor % 2 == 1 then "Shift" else empty end) ];
  .[]
  | select((.description // "") != "")
  | ((.modmask | mods) + [.key] | join(" + ")) as $combo
  | "\($combo)\t\(.description)"
' | awk -F'\t' '{ printf "  %-32s  →  %s\n", $1, $2 }')

if command -v rofi &>/dev/null; then
    printf '%s\n' "$LIST" | rofi -dmenu -i -p "Keybindings" \
        -theme-str 'window {width: 60%;} listview {lines: 25;}' -no-custom
else
    TMP=$(mktemp)
    trap 'rm -f "$TMP"' EXIT
    printf '%s\n' "$LIST" > "$TMP"
    kitty --title "Keybindings" -e less "$TMP"
fi
