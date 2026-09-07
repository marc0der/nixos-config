#!/usr/bin/env bash
set -euo pipefail

keygrip="$1"

# Assign inside the condition so `set -e` does not pre-empt the checks below.
# Lookup failure is treated as retryable: the secret service may not be up yet
# at login. systemd's StartLimit bounds the retries.
if ! secret=$(secret-tool lookup service gpg-agent keygrip "$keygrip" 2>/dev/null); then
  echo "no passphrase for $keygrip; store one with:" >&2
  echo "  secret-tool store --label=\"GPG key passphrase\" service gpg-agent keygrip $keygrip" >&2
  exit 1
fi

# Present but empty: nothing to preset, and retrying will not help.
[ -n "$secret" ] || exit 0
printf '%s' "$secret" | gpg-preset-passphrase --preset "$keygrip"
