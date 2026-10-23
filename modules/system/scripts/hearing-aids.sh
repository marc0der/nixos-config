# Block or unblock paired LE Audio hearing aids without powering off the adapter.
# Usage: hearing-aids on|off|toggle|status

csis_uuid="00001846-0000-1000-8000-00805f9b34fb"
ascs_uuid="0000184e-0000-1000-8000-00805f9b34fb"

# Paired devices in a coordinated set that stream LE Audio
aids() {
  local addr info
  bluetoothctl devices Paired 2>/dev/null | awk '{print $2}' | while read -r addr; do
    info=$(timeout 5 bluetoothctl info "$addr" 2>/dev/null) || continue
    if grep -q "$csis_uuid" <<<"$info" && grep -q "$ascs_uuid" <<<"$info"; then
      echo "$addr"
    fi
  done
}

blocked() {
  timeout 5 bluetoothctl info "$1" 2>/dev/null | grep -q "Blocked: yes"
}

off() {
  for addr in $devices; do
    timeout 10 bluetoothctl block "$addr" >/dev/null
  done
  notify "Hearing aids disconnected"
}

on() {
  for addr in $devices; do
    timeout 10 bluetoothctl unblock "$addr" >/dev/null
  done
  # Unblock can leave bluetoothd stuck on one aid; a restart clears it
  systemctl restart bluetooth.service
  notify "Hearing aids connecting"
}

status() {
  local addr
  for addr in $devices; do
    timeout 5 bluetoothctl info "$addr" 2>/dev/null |
      awk -v a="$addr" '/Blocked:/ {b=$2} /^\s*Connected:/ {c=$2} END {print a, "blocked=" b, "connected=" c}'
  done
}

notify() {
  echo "$1"
  notify-send -a "Hearing aids" -i audio-headphones "$1" 2>/dev/null || true
}

devices=$(aids)
if [[ -z $devices ]]; then
  echo "No paired hearing aids found" >&2
  exit 1
fi

case "${1:-toggle}" in
  on) on ;;
  off) off ;;
  status) status ;;
  toggle)
    any_blocked=false
    for addr in $devices; do
      blocked "$addr" && any_blocked=true
    done
    if $any_blocked; then on; else off; fi
    ;;
  *)
    echo "Usage: hearing-aids on|off|toggle|status" >&2
    exit 2
    ;;
esac
