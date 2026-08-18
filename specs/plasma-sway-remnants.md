# Plasma Session: Sway Remnants Specification

Status: in progress. Items 4 and 5 are implemented on this branch and
await testing. Items 2, 7, and 9 are partially addressed; see each item.

The items appear in implementation order. Item 1 comes first: the next
home-manager rebuild from HEAD breaks kanshi under Sway, so it must land
before any other item triggers a rebuild.
Scope: home-manager configuration for the `marco@neomorph` user. No changes
to `xenomorph` or to the Hyprland setup are in scope.

This document lists issues that break, weaken, or clash with the KDE Plasma
desktop session on `neomorph`. Home-manager applies the same profile to
every desktop session. A Sway-only setting that lacks a scope guard also
applies to the Plasma desktop session.

This document describes what to fix and why. It does not describe how to
fix each issue. Pick the implementation approach at build time.

An adversarial review checked this document against the repository and
against the Simplified Technical English rules. The review found two
causal links between items, one wrong priority order, one missing item, and
several wording problems. An earlier revision applied all of those
corrections.

A second review (2026-08-18) checked this document against the repository
at commit `b5bc82b` and against the live home directory. Two things changed
since the first revision:

- Commits on this branch already implement items 4 (`e81dc8f`) and 5
  (`b5bc82b`). A build-wrapper change (`81cc33a`) partially addresses
  item 9. A manual cleanup already deleted the files in item 2.
- A hard reset then discarded four later commits: a declarative kanshi
  unit (item 1), a ksecretd handover (item 3), a kwallet portal (item 10),
  and a docs amendment. The active home-manager generation still reflects
  that discarded work, plus some uncommitted work that is gone entirely.
  Several files in `$HOME` are therefore symlinks whose sources no longer
  exist in the repository, and the next rebuild from HEAD removes them.
  Do not treat on-disk state as evidence of repository state. Items 7 and
  1 describe the two concrete consequences; item 1 is the serious one.

This revision also renumbered the items into implementation order. Commit
messages older than this revision use the previous numbering: old item 9
became item 1, old items 1 through 8 each moved up by one number, and
item 10 kept its number.

## Constraints (from `rules/nixos-config.md`)

Every item below must follow the existing rules. In particular:

- Stage new or changed files with `git add` before you rebuild (RULE-001).
- Follow the build order: stage, then rebuild, then commit only after a
  successful build (RULE-002).
- Register new or moved modules in `flake.nix`. Do not add inline imports
  (RULE-003).
- Use the `/commit` skill for the commit (RULE-007).
- Build with the `bin/` wrapper scripts, not raw `nixos-rebuild` or
  `home-manager` commands (RULE-101).
- Ask for confirmation before you delete a file that this repository does
  not manage (RULE-105 covers directory changes; apply the same caution to
  file deletion outside the nix-managed tree).
- Do not report an item as fixed until the user tests the change under
  both the Sway and the Plasma desktop session and confirms it (RULE-106).

Items 1 and 2 point at files inside `$HOME` that home-manager does not
manage. Deleting those files is a manual step, not a nix change.

---

## 1. The kanshi unit needs a nix-managed replacement before cleanup

This item's first revision contained two wrong claims. The corrected
facts:

- `sway-startup.nix` starts kanshi through the unit, with
  `systemctl --user restart kanshi.service`, not through a direct command.
- Because of that, deleting the unit without a nix-managed replacement
  stops kanshi from starting under Sway and breaks output profile
  switching on `neomorph`.

### Current state
The hand-written unit, dated March 2025, contains:

```
BindsTo=sway-session.target
ExecStart=/usr/bin/env WAYLAND_DISPLAY=wayland-1 kanshi
Environment=PATH=%h/.nix-profile/bin:/usr/bin:/bin
WantedBy=sway-session.target
```

Three problems with it:

- `WAYLAND_DISPLAY=wayland-1` is hardcoded, the same wrong-display
  pattern as item 2.
- `PATH` names `/usr/bin` and `/bin`, which do not exist on NixOS, and
  resolves `kanshi` through `~/.nix-profile/bin` rather than through the
  nix store.
- The file is unmanaged, so no rebuild can repair or replace it.

The 2026-08-18 review found the on-disk state moved again, and in a way
that makes this item urgent. A rebuild from since-discarded work displaced
the hand-written unit to `~/.config/systemd/user/kanshi.service.backup`
and installed a home-manager symlink at
`~/.config/systemd/user/kanshi.service`. The commit that declared that
unit (`d052885`) was then discarded in the hard reset, and no module at
HEAD declares any kanshi unit: `modules/home/kanshi.nix` writes only
`~/.config/kanshi/config`, and no `services.kanshi` option is set anywhere
in the repository.

The next rebuild from HEAD therefore removes the orphaned symlink and
leaves no `kanshi.service` at all. The `systemctl --user restart
kanshi.service` command in `sway-startup.nix` then fails, and kanshi never
starts under Sway. Implement this item before, or in the same change as,
the next home-manager rebuild.

The unit is inactive under a Plasma desktop session, because
`sway-session.target` is inactive there. That is correct behaviour and
must be kept.

### Desired outcome
`kanshi` starts under Sway through a nix-managed systemd user unit. The
unit resolves the kanshi binary from the nix store, inherits
`WAYLAND_DISPLAY` from the session rather than hardcoding it, and stays
bound to `sway-session.target` so it never starts under Plasma. No
unmanaged kanshi unit file remains on disk, including
`kanshi.service.backup`. Deleting the `.backup` file is a manual step
outside the nix-managed tree; ask first, per the constraints above.

### Advantage
- Keeps output profile switching working under Sway after the next
  rebuild, which the current HEAD breaks.
- Removes the last hardcoded `wayland-1` value from the user's systemd
  tree.
- Puts kanshi on the same declarative footing as every other user service
  in this repository.
- Keeps `sway-startup.nix` working unchanged: the same
  `systemctl --user restart kanshi.service` command drives the new unit.

### Acceptance criteria
- `~/.config/systemd/user/kanshi.service` is a symlink into the nix
  store, not a hand-written file.
- The unit's `ExecStart` names a `/nix/store` path for the kanshi binary.
- The unit sets no `WAYLAND_DISPLAY` value.
- Under Sway, `systemctl --user is-active kanshi.service` reports
  `active`, and kanshi applies its output profile on startup and on
  monitor hotplug.
- Under Plasma, `kanshi.service` is inactive and does not appear as
  failed.
- `modules/home/sway-startup.nix` needs no change.
- `~/.config/systemd/user/kanshi.service.backup` does not exist.

---

## 2. Stale systemd overrides force the wrong Wayland display name

### Current state
Partially done: a manual cleanup on 2026-08-17 already deleted both files
and their directories. What remains is the verification in the acceptance
criteria below.

Two files existed under `~/.config/systemd/user/`. Neither file belonged
to the nix-managed configuration. Both predated this investigation by over
a year, the same kind of leftover file as `~/.config/environment.d/wayland.conf`,
which this project already removed:

- `xdg-desktop-portal-gtk.service.d/override.conf`
- `xdg-desktop-portal-wlr.service.d/override.conf`

Both files set `WAYLAND_DISPLAY=wayland-1` and `DISPLAY=:1`. The current
Plasma desktop session uses `wayland-0`, not `wayland-1`. Under Plasma, the
GTK portal fails to start because of this mismatch: `cannot open display
:1`. The GTK portal carries the dark-mode setting and the file-open dialog
for GTK and Electron apps.

Under Sway, the same override may or may not cause a problem: Sway
commonly names its own display `wayland-1`, so the forced value may already
match. This document did not test the Sway case.

### Desired outcome
Neither override file exists. The GTK portal reaches an active state under
Plasma. Under Sway, the GTK portal keeps working exactly as it does today.

### Advantage
- Restores the dark-mode setting and file dialogs for GTK and Electron
  apps under Plasma.
- Removes leftover configuration that matches neither desktop session by
  design, only by coincidence.

### Acceptance criteria
- Neither override file exists under `~/.config/systemd/user/`.
- `xdg-desktop-portal-gtk.service` reaches the `active` state under the
  Plasma desktop session.
- Under the Sway desktop session, the dark-mode setting and file dialogs
  still work for GTK and Electron apps.

---

## 3. The Sway keyring daemon blocks secret-unlock prompts

### Current state
`modules/home/keyring-services.nix` starts `gnome-keyring-daemon` with no
desktop-session guard. `gnome-keyring-daemon` claims the
`org.freedesktop.secrets` D-Bus name before Plasma's own secret service,
`ksecretd`, can claim it. `gnome-keyring-daemon` needs a separate prompt
helper to show an unlock dialog, and that helper is not installed. Under
Plasma, an app that asks for a secret gets no unlock prompt.

The missing prompt helper is not tied to Plasma. The same missing prompt
may also affect the Sway desktop session. This document did not test the
Sway case.

A commit that implemented this item (`ba82a28`) was discarded in the hard
reset of 2026-08-18. The repository at HEAD carries no fix. Treat this
item as open, and do not reuse the discarded implementation without
review.

### Desired outcome
Under Plasma, `ksecretd` owns the secrets service, and unlock prompts
appear for apps that need one. Under Sway, the keyring setup keeps working
exactly as it does today, or gains the same working prompt if the Sway case
turns out to share this problem.

### Advantage
- Apps that store secrets (browsers, VPN clients, mail clients) can ask
  the user to unlock a secret under Plasma.
- Removes a silent failure that gives the user no error and no prompt.

### Acceptance criteria
- Under Plasma, `ksecretd` owns the `org.freedesktop.secrets` D-Bus name.
- An app that requests a secret shows an unlock prompt under Plasma.
- Under Sway, no secret-prompt behavior that works today stops working.

---

## 4. The Sway polkit agent fights Plasma's own agent

### Current state
Implemented on this branch, awaiting test. Commit `e81dc8f` added a
`polkitSessionTarget` option to `modules/home/keyring-services.nix`
(default `graphical-session.target`), and `hosts/neomorph/home.nix` sets
it to `sway-session.target`. Under Plasma, the agent unit no longer has an
active trigger. Per RULE-106, do not report this item as fixed until the
user confirms the acceptance criteria under both desktop sessions.

The original problem: `modules/home/keyring-services.nix` started
`polkit-gnome-authentication-agent-1` as a systemd user service, with no
desktop-session guard. It also started under Plasma. Plasma already runs
its own polkit agent. Only one agent can register per desktop session. The
Sway agent's registration failed, and systemd restarted it every 3
seconds, for the whole length of the Plasma desktop session.

### Desired outcome
Under Plasma, only Plasma's own polkit agent runs. Under Sway, the Sway
polkit agent still starts once and stays up, exactly as it does today.

### Advantage
- Removes a restart loop that runs for the whole length of the Plasma
  desktop session.
- Removes constant log noise from the failed registration.
- Frees the CPU and process-table churn the loop causes.

### Acceptance criteria
- Under Plasma, `polkit-gnome-authentication-agent-1` does not start.
- Under Sway, `polkit-gnome-authentication-agent-1` starts once and stays
  active.

---

## 5. The Sway screen-capture portal starts under Plasma and fails

### Current state
Implemented on this branch, awaiting test. Commit `b5bc82b` binds the
`xdg-desktop-portal-wlr` unit in `modules/home/xdg-portal-sway.nix` to
`sway-session.target` through `PartOf` and `WantedBy`, so it no longer
starts under Plasma. Per RULE-106, do not report this item as fixed until
the user confirms the acceptance criteria under both desktop sessions.

The original problem: the module started `xdg-desktop-portal-wlr` as a
systemd user service, with no desktop-session guard. Under Plasma, the
service failed to reach an active state and hit the systemd restart limit.
The unit stayed in a `failed` state for the rest of the desktop session.

The service failed with `wayland: failed to connect to display`. This is
not a knock-on effect of item 2: the failure was recorded in a session
where item 2's override files were already gone. The problem is simply
that this service has no reason to start at all under a desktop session
that does not use Sway or wlroots.

### Desired outcome
`xdg-desktop-portal-wlr` starts only under Sway. It neither starts nor
fails under Plasma.

### Advantage
- Removes a service with no chance of success from every Plasma login.
- Keeps the Plasma desktop session free of unrelated failed units.

### Acceptance criteria
- Under Plasma, `xdg-desktop-portal-wlr.service` does not appear in
  `systemctl --user list-units`.
- Under Sway, `xdg-desktop-portal-wlr.service` still starts and stays
  active.

---

## 6. Global GTK and cursor theme variables override Plasma's own theme

### Current state
`modules/home/gtk-theme.nix` sets `GTK_THEME=Materia-dark` as a global
session variable. `modules/home/session-variables.nix` sets
`XCURSOR_THEME=Bibata-Modern-Ice` the same way. Both variables apply to
every desktop session, including Plasma. `GTK_THEME` overrides Plasma's own
Breeze GTK theme for every GTK app. `XCURSOR_THEME` overrides Plasma's
cursor choice for every Wayland and XWayland app.

This project already fixed one variable of the same kind,
`QT_QPA_PLATFORMTHEME`, because it caused the same problem for Qt apps.

An investigation while building this spec found that neither variable can
be fully unset by removing it from `home.sessionVariables` alone, because
each has a second, independent source. Both open decisions below were
raised with the user and answered; this revision folds the answers in and
replaces the single item 6 with two sub-items, 6a and 6b, that carry the
corrected, resolvable outcome.

### 6a. `GTK_THEME`

The `gtk.enable` option in `home.nix`, with the theme name that
`modules/home/gtk-theme.nix` sets through `gtk.theme.name`, writes
`gtk-theme-name=Materia-dark` directly into the home-manager-managed
`~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini`. The
`GTK_THEME` session variable itself also comes from
`modules/home/gtk-theme.nix`, not from `home.nix`. The `settings.ini`
files carry no session scoping, so
removing the `GTK_THEME` env var does not hand Plasma its Breeze GTK theme;
GTK apps under Plasma still read `Materia-dark` from `settings.ini`
regardless.

**Decision:** accept this. Remove `GTK_THEME` from the global session
variables anyway. That change is still correct and low-risk, because it
stops the env var from overriding any per-app or Plasma-side choice, and
`Materia-dark` is visually coherent with Breeze Dark. Handing GTK file
management to `kde-gtk-config` instead (dropping `gtk.enable` theming from
home-manager) would resolve the colour-leak, `-b backup`, and `GTK_THEME`
items together, but is a large change that needs its own spec; it is out of
scope here.

#### Desired outcome
`GTK_THEME` is no longer a global session variable; it applies only under
Sway and Hyprland. Under Plasma, GTK apps show `Materia-dark`, read from
`settings.ini` rather than from the env var.

#### Acceptance criteria
- Under Plasma, `GTK_THEME` is not part of the session environment.
- Under Sway and Hyprland, `GTK_THEME` still resolves to `Materia-dark` and
  GTK apps look unchanged.

### 6b. `XCURSOR_THEME`

`XCURSOR_THEME=Bibata-Modern-Ice` has three independent sources, not one:
the global session variable itself, `home.pointerCursor`'s own
`XCURSOR_THEME = mkDefault cfg.name` export (fired whenever
`home.pointerCursor` is enabled), and `gtk-cursor-theme-name=Bibata-Modern-Ice`
in the home-manager-managed `~/.config/gtk-3.0/settings.ini`. Removing only
the session variable leaves the other two in place, so the literal
acceptance criterion below ("not part of the session environment") cannot
be met by that change alone.

**Decision:** stop trying to unset `XCURSOR_THEME`. `home.pointerCursor`
legitimately declares Bibata as the user's cursor for every session;
instead set Plasma's own cursor theme, through Plasma's system settings, to
`Bibata-Modern-Ice`, so nothing clashes. This meets the intent of this
item, one consistent cursor under Plasma, but not the original literal
wording. Guarding the whole `home.pointerCursor` block per compositor
instead was considered and rejected: it would also drop the `~/.icons` and
`~/.local/share/icons` management that option provides, and would widen the
blast radius onto xenomorph, which is out of scope for this document.

#### Desired outcome
Under Plasma, the cursor is `Bibata-Modern-Ice`, set through Plasma's own
cursor-theme setting, so no second source fights it. Under Sway and
Hyprland, the cursor keeps resolving to `Bibata-Modern-Ice` exactly as it
does today.

#### Acceptance criteria
- Under Plasma, the cursor theme is `Bibata-Modern-Ice`, set via Plasma's
  own setting, with no other source overriding it.
- Under Sway and Hyprland, the cursor is still `Bibata-Modern-Ice` at size
  24.

---

## 7. Two Bluetooth tray applets start at the same time under Plasma

### Current state
`modules/home/desktop-common.nix` installs the `blueman` package. The
package's autostart entry carries no desktop-session guard, unlike the
autostart entry for `nm-applet`, which already excludes Plasma. Under
Plasma, `blueman-applet` starts next to Plasma's own Bluetooth tray,
`bluedevil`. Two tray icons appear, and two separate agents can offer a
pairing dialog for the same device.

A separate Sway startup list, in `modules/home/sway-startup.nix`, also
starts `blueman-applet` directly. A fix to the autostart entry does not
touch that separate list, so Sway keeps its Bluetooth applet either way.

A fix for this item exists on disk right now, but not in the repository.
`~/.config/autostart/blueman.desktop` is a home-manager symlink to an
entry that carries `NotShowIn=KDE;`. Its source came from uncommitted work
that the 2026-08-18 hard reset and cleanup discarded; no commit at HEAD
declares it. The next rebuild from HEAD removes the override, and
`blueman-applet` autostarts under Plasma again. The fix must land in the
repository to hold.

### Desired outcome
Under Plasma, only `bluedevil` manages Bluetooth pairing and shows a tray
icon. Under Sway, `blueman-applet` still starts, exactly as it does today.

### Advantage
- One Bluetooth tray icon and one pairing dialog under Plasma.
- Removes a source of duplicate pairing prompts for the same device.

### Acceptance criteria
- Under Plasma, `blueman-applet` does not start through the autostart
  path.
- Under Sway, `blueman-applet` still starts.

---

## 8. Plasma's GTK-theme sync already leaked Breeze colors into Sway

### Current state
Plasma's GTK-theme sync tool, `kde-gtk-config`, wrote three files that
home-manager does not manage: `~/.config/gtk-3.0/gtk.css`,
`~/.config/gtk-3.0/colors.css`, and `~/.config/gtk-4.0/colors.css`. The
GTK3 `gtk.css` contains only `@import 'colors.css';`, and both `colors.css`
files carry Breeze colors. Every GTK3 app that reads these files gets
Breeze colors instead of the `Materia-dark` color set, and this already
happens under the Sway desktop session too, because the files are not tied
to either session. Plasma rewrote all three files on 2026-08-17, so the
leak is current, not historical.

### Desired outcome
A GTK3 app under Sway uses the `Materia-dark` color set, not a Breeze
color set picked up from an unmanaged file.

### Advantage
- Restores a consistent Sway GTK3 look that matches the rest of the Sway
  theme.
- Removes an unmanaged file that a future Plasma theme change can rewrite
  again at any time.

### Acceptance criteria
- Under Sway, a GTK3 app shows the `Materia-dark` color set.
- `~/.config/gtk-3.0/gtk.css` either does not exist or does not import a
  Breeze color file.
- `~/.config/gtk-3.0/colors.css` either does not exist or does not carry
  Breeze colors.

---

## 9. Plasma settings pages can overwrite home-manager-managed theme files

### Current state
Home-manager's `gtk.enable` option, set in `home.nix`, manages four files.
One of the four, `~/.gtkrc-2.0`, already suffered this exact problem once:
Plasma's GTK-theme sync tool overwrote the home-manager symlink with a
plain file, and the next home-manager build then failed, because
home-manager refuses to replace a file it does not already own.

The other three files carry the same risk, because the same sync tool
writes to all four file names, not only to `~/.gtkrc-2.0`:

- `~/.config/gtk-3.0/settings.ini`
- `~/.config/gtk-4.0/settings.ini`
- `~/.config/gtk-4.0/gtk.css`

`home.nix` also manages a fifth file, `~/.icons/default/index.theme`,
through the `home.pointerCursor` option. Plasma's cursor-theme setting page
may write to the same file path when the user changes the cursor theme
through Plasma. This document did not test that case, so treat it as an
open risk, not a confirmed one.

Two updates from the 2026-08-18 review:

- The `.gtkrc-2.0` failure is live again: Plasma rewrote
  `~/.gtkrc-2.0` as a plain file on 2026-08-17, so it is not a
  home-manager symlink right now.
- Commit `81cc33a` changed the `bin/` build wrappers to back up a
  displaced file and continue, instead of failing the build. The
  `kanshi.service.backup` file under `~/.config/systemd/user/` shows this
  mechanism working. This likely meets both acceptance criteria already,
  awaiting test. Note the trade-off it locks in: a rebuild displaces
  Plasma's version to a `.backup` file and restores the home-manager
  symlink, so a theme change made through Plasma silently reverts on the
  next rebuild. That is consistent with a declarative setup; this item
  needs no further work unless the user rejects that trade-off.

### Desired outcome
A theme or cursor change made through a Plasma settings page does not
block the next home-manager build, for any of the five files above.

### Advantage
- Removes repeats of the `.gtkrc-2.0` build failure for the remaining
  files.
- Removes a manual backup-and-retry step from future Plasma theme changes.

### Acceptance criteria
- After a GTK-theme change through a Plasma settings page, the next
  home-manager build succeeds without a manual file move first.
- After a cursor-theme change through a Plasma settings page, the next
  home-manager build succeeds without a manual file move first.

---

## 10. The secret-storage portal stays hidden from sandboxed apps

### Current state
Home-manager's `xdg.portal` option sets `NIX_XDG_DESKTOP_PORTAL_DIR` to a
folder that holds only the GTK, KDE, and wlr portal implementations. The
system-wide portal folder also holds a kwallet portal implementation, which
pairs with Plasma's `ksecretd` secret service. Because
`NIX_XDG_DESKTOP_PORTAL_DIR` points only at the narrower folder,
`xdg-desktop-portal` cannot see the kwallet portal implementation. This
affects only a sandboxed app, such as a Flatpak app, that asks for a secret
through the portal. It does not affect a regular desktop app.

A commit that implemented this item (`ff7b0c7`) was discarded in the hard
reset of 2026-08-18. The repository at HEAD carries no fix. Treat this
item as open, and do not reuse the discarded implementation without
review. This item also depends on item 3: the kwallet portal is only
useful once `ksecretd` owns the secrets service.

### Desired outcome
A sandboxed app can ask for a secret through the portal and reach Plasma's
`ksecretd` secret service.

### Advantage
- Gives a sandboxed app the same secret-storage path a regular desktop app
  already has under Plasma.

### Acceptance criteria
- A Flatpak app can request a secret through the portal and get a response
  from `ksecretd` under Plasma.
