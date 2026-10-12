# Power-cycle the adapter once bluetoothd has enabled ISO support,
# so the controller is re-initialised with LE Audio host support set.

iso_uuid="6fbaf188-05e0-496a-9885-d6ddfdb4e03e"
timeout_s=30

show() {
  timeout 5 bluetoothctl show 2>/dev/null || true
}

for ((i = 0; i < timeout_s; i++)); do
  state=$(show)
  if grep -q "$iso_uuid" <<<"$state" && grep -q "Powered: yes" <<<"$state"; then
    echo "ISO support enabled and adapter powered, re-initialising"
    timeout 10 bluetoothctl power off >/dev/null
    timeout 10 bluetoothctl power on >/dev/null
    if grep -q "Powered: yes" <<<"$(show)"; then
      echo "Adapter re-initialised with LE Audio support"
    else
      echo "Adapter did not power back on" >&2
    fi
    exit 0
  fi
  sleep 1
done

echo "Gave up after ${timeout_s}s: ISO support not enabled or adapter not powered" >&2
exit 0
