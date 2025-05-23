#!/usr/bin/env bash
#  _____                 _   _______ _                        
# |  __ \               | | |__   __| |                       
# | |__) |   _ __      _| |___ | |  | |__   ___ _ __ ___   ___ 
# |  ___/ | | |\ \ /\ / / __| \| |  | '_ \ / _ \ '_ ` _ \ / _ \
# | |   | |_| | \ V  V /| |_ \ | |  | | | |  __/ | | | | |  __/
# |_|    \__, |  \_/\_/  \__| \|_|  |_| |_|\___|_| |_| |_|\___|
#         __/ |                                               
#        |___/                                                
#

# Script to apply pywal theme to the current wallpaper

# Check if the wallpaper exists
if [ -f ~/.wallpaper.jpg ]; then
  # Delete pywal cache to ensure fresh generation
  echo "Deleting pywal cache..."
  rm -rf ~/.cache/wal/*
  
  # Apply the theme
  wal -i ~/.wallpaper.jpg

  # Notify the user
  echo "Pywal theme applied to ~/.wallpaper.jpg"
  
  # Reload window manager styling if it's running
  if pgrep -x "hyprland" > /dev/null; then
    hyprctl reload
  elif pgrep -x "sway" > /dev/null; then
    swaymsg reload
  fi
else
  echo "Error: ~/.wallpaper.jpg not found"
  exit 1
fi