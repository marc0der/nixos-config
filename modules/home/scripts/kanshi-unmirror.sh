#!/usr/bin/env bash
# Stop any running screen mirror. Called by kanshi's laptop-only profile so the
# wl-mirror process does not linger after the external display is unplugged.

pkill -x wl-mirror 2>/dev/null || true
