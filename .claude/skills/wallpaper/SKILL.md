---
name: wallpaper
description: Set the desktop wallpaper on this host. Repoints ~/.wallpaper.jpg to an image in ~/Pictures/Wallpapers, regenerates the pywal palette, and reloads hyprpaper. Use when the user runs "/wallpaper <filename>" or asks to change the desktop wallpaper.
argument-hint: <filename-in-Wallpapers-or-absolute-path>
---

# Set wallpaper

Run the backing script with the user's argument:

```bash
bash .claude/skills/wallpaper/set-wallpaper.sh "$ARGUMENTS"
```

The argument is either a bare filename (resolved against `~/Pictures/Wallpapers`)
or an absolute path. The script:

1. Repoints the `~/.wallpaper.jpg` symlink at the target image.
2. Regenerates the pywal palette with `wal -i ~/.wallpaper.jpg -b "#0c0e10"`
   (the dark background flag avoids the pywal16 purple tint).
3. Restarts the `hyprpaper` user service so it re-reads the link.

If the script reports an error (missing file), relay it. On success, confirm the
wallpaper that was set. This is a runtime change only — nothing in the Nix repo
changes, so there is nothing to rebuild or commit.
