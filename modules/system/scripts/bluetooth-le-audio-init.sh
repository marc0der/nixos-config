# Power-cycle the adapter once bluetoothd has enabled ISO support,
# so the controller is re-initialised with LE Audio host support set.

iso_uuid="6fbaf188-05e0-496a-9885-d6ddfdb4e03e"
timeout_s=30
power_on_attempts=10

show() {
  timeout 5 bluetoothctl show 2>/dev/null || true
}

powered() {
  grep -q "PowerState: on$" <<<"$(show)"
}

for ((i = 0; i < timeout_s; i++)); do
  state=$(show)
  if grep -q "$iso_uuid" <<<"$state" && grep -q "Powered: yes" <<<"$state"; then
    echo "ISO support enabled and adapter powered, re-initialising"
    timeout 10 bluetoothctl power off || echo "Power off failed" >&2
    for ((j = 0; j < power_on_attempts; j++)); do
      timeout 10 bluetoothctl power on || true
      if powered; then
        echo "Adapter re-initialised with LE Audio support"
        exit 0
      fi
      sleep 1
    done
    echo "Adapter did not power back on after ${power_on_attempts} attempts" >&2
    exit 1
  fi
  sleep 1
done

echo "Gave up after ${timeout_s}s: ISO support not enabled or adapter not powered" >&2
exit 0
