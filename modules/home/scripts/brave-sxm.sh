#!/usr/bin/env bash
# Brave (SiriusXM VPN)
#
# Launches a dedicated Brave instance routed through the GlobalProtect VM's
# tinyproxy. Uses a separate --user-data-dir so --proxy-server reliably
# applies (Chromium ignores the flag when a launch attaches to an existing
# instance) and stays isolated from the other Brave profiles.

exec brave \
  --enable-features=UseOzonePlatform \
  --ozone-platform=wayland \
  --user-data-dir="$HOME/.local/share/brave-sxm" \
  --proxy-server="http://192.168.122.96:8888" \
  --proxy-bypass-list="localhost;127.0.0.1" \
  "$@"
