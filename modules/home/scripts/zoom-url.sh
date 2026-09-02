#!/usr/bin/env bash
# Hand Zoom URLs to the Zoom client intact.
#
# Two jobs:
#
#  1. KDE's KIO (kde-open, and xdg-open which delegates to it) re-serialises
#     custom-scheme URLs with an empty authority, so zoommtg://zoom.us/join
#     arrives as zoommtg:///zoom.us/join. Zoom cannot parse the host in that
#     form, which breaks meeting links and the SSO sign-in callback.
#
#  2. Converts https Zoom join links and bare meeting IDs into zoommtg URLs,
#     so a calendar link can be opened in the client without a browser round
#     trip: `zoom-url https://us02web.zoom.us/j/123?pwd=abc`

set -euo pipefail

# Dispatch log, for diagnosing browser-to-client handoff failures
log="${XDG_CACHE_HOME:-$HOME/.cache}/zoom-url.log"
printf '%s  argv: %s\n' "$(date -Is)" "$*" >>"$log" 2>/dev/null || true

zoom=$(command -v zoom 2>/dev/null || true)
[ -n "$zoom" ] || zoom="$HOME/.nix-profile/bin/zoom"

# https join link or bare meeting id -> zoommtg URL; echoes nothing if no match
to_zoommtg() {
  local url=$1 host id pw
  if [[ $url =~ ^https?://([^/]+)/(j|wc/join)/([0-9]+) ]]; then
    host=${BASH_REMATCH[1]}
    id=${BASH_REMATCH[3]}
    pw=""
    [[ $url =~ [?\&]pwd=([^\&#]+) ]] && pw=${BASH_REMATCH[1]}
    if [ -n "$pw" ]; then
      printf 'zoommtg://%s/join?confno=%s&pwd=%s' "$host" "$id" "$pw"
    else
      printf 'zoommtg://%s/join?confno=%s' "$host" "$id"
    fi
  elif [[ $url =~ ^[0-9]{9,12}$ ]]; then
    printf 'zoommtg://zoom.us/join?confno=%s' "$url"
  fi
}

args=()
for arg in "$@"; do
  case $arg in
    zoommtg:///* | zoomus:///* | zoomphonecall:///* | zoomphonesms:///* | zoomcontactcentercall:///*)
      scheme=${arg%%:*}
      args+=("$scheme://${arg#"$scheme":///}")
      ;;
    http://*zoom.us/* | https://*zoom.us/* | [0-9]*)
      converted=$(to_zoommtg "$arg")
      args+=("${converted:-$arg}")
      ;;
    *)
      args+=("$arg")
      ;;
  esac
done

exec "$zoom" ${args[@]+"${args[@]}"}
