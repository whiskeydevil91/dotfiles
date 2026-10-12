#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# wallpaper.sh
# Sets the desktop background on every monitor using swaybg.
#
# Usage:
#   wallpaper.sh                 # use the default wallpaper
#   wallpaper.sh /path/to/image  # use a different image
# ------------------------------------------------------------

DEFAULT_WALLPAPER="$HOME/Pictures/Wallpapers/default.png"
WALLPAPER="${1:-$DEFAULT_WALLPAPER}"

if [[ ! -f "$WALLPAPER" ]]; then
  echo "ERROR: Wallpaper not found at $WALLPAPER" >&2
  exit 1
fi

if ! command -v swaybg &>/dev/null; then
  echo "ERROR: swaybg is not installed" >&2
  exit 1
fi

# Replace any running instance so the new image takes over
pkill -x swaybg 2>/dev/null || true

# Fill each monitor (scale to cover, cropping edges if needed)
swaybg -i "$WALLPAPER" -m fill >/dev/null 2>&1 &
disown
