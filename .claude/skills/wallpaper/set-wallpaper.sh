#!/usr/bin/env bash
# Set the desktop wallpaper on this host.
#
# Repoints ~/.wallpaper.jpg (the file hyprpaper and hyprlock reference) at an
# image, regenerates the pywal palette, and restarts hyprpaper so it re-reads
# the link. The argument is a filename in ~/Pictures/Wallpapers or an absolute
# path.
#
# Usage:
#   set-wallpaper.sh <filename-in-Wallpapers | /absolute/path>
set -euo pipefail

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
LINK="$HOME/.wallpaper.jpg"
PYWAL_BG="#0c0e10"

arg="${1:-}"
if [[ -z "$arg" ]]; then
  echo "usage: set-wallpaper.sh <filename-in-Wallpapers | /absolute/path>" >&2
  exit 1
fi

if [[ -f "$arg" ]]; then
  target="$arg"
else
  target="$WALLPAPER_DIR/$arg"
fi

if [[ ! -f "$target" ]]; then
  echo "error: wallpaper not found: $target" >&2
  exit 1
fi
target="$(realpath "$target")"

ln -sfn "$target" "$LINK"
wal -i "$LINK" -b "$PYWAL_BG"
systemctl --user restart hyprpaper.service

echo "wallpaper set: $target"
