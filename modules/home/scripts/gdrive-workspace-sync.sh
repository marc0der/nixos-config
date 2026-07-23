#!/usr/bin/env bash
# Two-way sync of the SiriusXM team drive (sxm:) with the local folder
# ~/SharedDrives/Workspace. Establishes the bisync baseline with --resync on
# first run (tracked by a sentinel), then runs incremental bisync thereafter.
# --fast-list pages the whole tree in ~2 API calls instead of walking every
# folder. Invoked by the 3-minute pull timer and the inotify push watcher.
set -euo pipefail

remote="sxm:"
local_dir="$HOME/SharedDrives/Workspace"
state_dir="$HOME/.cache/rclone/bisync"
sentinel="$state_dir/.workspace-initialized"
lock="$state_dir/.workspace.lock"
log="/tmp/rclone-workspace-sync.log"

mkdir -p "$local_dir" "$state_dir"

# Never run two syncs at once; skip this trigger if one is already running.
exec 9>"$lock"
flock -n 9 || exit 0

common=(
  --fast-list
  --resilient
  --create-empty-src-dirs
  --conflict-resolve=newer
  --log-file "$log"
  --log-level INFO
)

if [[ ! -f "$sentinel" ]]; then
  rclone bisync "$remote" "$local_dir" --resync "${common[@]}"
  touch "$sentinel"
else
  rclone bisync "$remote" "$local_dir" "${common[@]}"
fi
