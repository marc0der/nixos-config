#!/usr/bin/env bash
# Watch ~/SharedDrives/Workspace and trigger a bisync shortly after local
# edits settle, so writes push to the team drive within seconds. A short
# debounce coalesces bursts of edits into a single sync; systemd coalesces
# overlapping triggers with the 3-minute pull timer.
set -euo pipefail

local_dir="$HOME/SharedDrives/Workspace"
mkdir -p "$local_dir"

while true; do
  inotifywait -r -q \
    -e modify,create,delete,move,close_write \
    "$local_dir" >/dev/null 2>&1 || true
  # Debounce: let a burst of edits settle before syncing.
  sleep 5
  systemctl --user start --no-block gdrive-workspace-sync.service || true
done
