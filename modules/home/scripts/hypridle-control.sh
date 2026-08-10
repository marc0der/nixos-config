#!/usr/bin/env bash
# hypridle-control — drive the waybar custom/hypridle idle-inhibitor widget.
#
#   status  emit waybar JSON (class active|notactive) from the systemd service state
#   toggle  start/stop the hypridle user service (manual stop overrides Restart=always)

service="hypridle.service"

is_active() {
  systemctl --user is-active --quiet "$service"
}

emit_status() {
  if is_active; then
    printf '{"class":"active","tooltip":"Idle daemon running — screen will lock and sleep"}\n'
  else
    printf '{"class":"notactive","tooltip":"Idle daemon stopped — screen stays awake"}\n'
  fi
}

case "$1" in
  status)
    emit_status
    ;;
  toggle)
    if is_active; then
      systemctl --user stop "$service"
      command -v notify-send >/dev/null && notify-send -e "Idle daemon" "Stopped — screen stays awake"
    else
      systemctl --user start "$service"
      command -v notify-send >/dev/null && notify-send -e "Idle daemon" "Started — screen will lock and sleep"
    fi
    emit_status
    ;;
  *)
    echo "usage: hypridle-control {status|toggle}" >&2
    exit 1
    ;;
esac
