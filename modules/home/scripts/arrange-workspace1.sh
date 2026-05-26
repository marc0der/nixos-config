#!/usr/bin/env bash
# Arrange workspace 1: Slack (left, 33%) + Brave (right, 67%).
# Launches Slack first, then Brave, so Slack deterministically takes the left column.

slack_id='brave-app\.slack\.com.*'
brave_id='brave-browser'

has_window() {
  swaymsg -t get_tree | grep -qE "\"app_id\": \"$1\""
}

wait_for() {
  for _ in $(seq 1 100); do
    has_window "$1" && return 0
    sleep 0.1
  done
  return 1
}

swaymsg 'workspace number 1' >/dev/null

# Slack first -> left column
if ! has_window "$slack_id"; then
  brave --new-window --enable-features=UseOzonePlatform --ozone-platform=wayland \
    --profile-directory=Default --app="https://app.slack.com/client/T02QA1EAG" >/dev/null 2>&1 &
  wait_for "$slack_id"
fi

# Brave second -> right column
if ! has_window "$brave_id"; then
  brave --enable-features=UseOzonePlatform --ozone-platform=wayland >/dev/null 2>&1 &
  wait_for "$brave_id"
fi

# Widths: Slack 33%, Brave fills the rest
swaymsg "[app_id=\"$slack_id\"] resize set width 33 ppt" >/dev/null
