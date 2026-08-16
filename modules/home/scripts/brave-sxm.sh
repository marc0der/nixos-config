#!/usr/bin/env bash
# Brave (SiriusXM)
#
# Opens the SiriusXM Brave profile in the normal Brave instance. Proxy
# routing for this profile is provided by a proxy extension installed
# within the profile itself: Chromium has no reliable per-profile proxy
# flag, and running a separate --user-data-dir instance destabilises the
# main Brave process (observed SIGTRAP crashes of the default instance).

exec brave \
  --new-window \
  --enable-features=UseOzonePlatform \
  --ozone-platform=wayland \
  --profile-directory=SiriusXM \
  "$@"
