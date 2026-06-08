#!/usr/bin/env bash
# Mirror the laptop screen (eDP-1) to the first connected external display.
# Called by kanshi's mirror profile; handles any output name (HDMI, DP, etc.).

pkill -x wl-mirror 2>/dev/null || true
sleep 0.5

PROJECTOR=$(swaymsg -t get_outputs \
  | jq -r '[.[] | select(.active and .name != "eDP-1") | .name][0] // empty')

if [ -n "$PROJECTOR" ]; then
  exec wl-mirror --fullscreen-output "$PROJECTOR" eDP-1
fi
