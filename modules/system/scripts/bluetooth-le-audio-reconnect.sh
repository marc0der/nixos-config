# Reconnect LE Audio devices that connected before WirePlumber was ready,
# so BlueZ sets up their audio endpoints again and PipeWire gets a card.

pacs_uuid="00001850-0000-1000-8000-00805f9b34fb"
settle_s=5
attempts=3

# Connected devices that support LE Audio but have no PipeWire card
missing() {
  local cards addr
  cards=$(pw-cli ls Device 2>/dev/null || true)
  bluetoothctl devices Connected 2>/dev/null | awk '{print $2}' | while read -r addr; do
    timeout 5 bluetoothctl info "$addr" 2>/dev/null | grep -q "$pacs_uuid" || continue
    grep -q "bluez_card.${addr//:/_}\"" <<<"$cards" || echo "$addr"
  done
}

sleep "$settle_s"
for ((i = 0; i < attempts; i++)); do
  devices=$(missing)
  if [[ -z $devices ]]; then
    echo "All connected LE Audio devices have an audio card"
    exit 0
  fi
  for addr in $devices; do
    echo "Reconnecting $addr"
    timeout 10 bluetoothctl disconnect "$addr" || true
  done
  sleep 2
  for addr in $devices; do
    timeout 15 bluetoothctl connect "$addr" || true
  done
  sleep "$settle_s"
done

echo "Still missing an audio card: $(missing | tr '\n' ' ')" >&2
exit 1
