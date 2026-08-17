# Plasma Session: Sway Remnants Specification

Status: proposed
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
several wording problems. This revision applies all of those corrections.

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

Item 1 points at files inside `$HOME` that home-manager does not manage.
Deleting those files is a manual step, not a nix change.

---

## 1. Stale systemd overrides force the wrong Wayland display name

### Current state
Two files exist under `~/.config/systemd/user/`. Neither file belongs to
the nix-managed configuration. Both predate this investigation by over a
year, the same kind of leftover file as `~/.config/environment.d/wayland.conf`,
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

**Note:** Item 4 (the Sway screen-capture portal) shows a failure with the
same wrong display name. Re-check item 4 after you fix this item — the
failure in item 4 may change or disappear once this override is gone.

### Acceptance criteria
- Neither override file exists under `~/.config/systemd/user/`.
- `xdg-desktop-portal-gtk.service` reaches the `active` state under the
  Plasma desktop session.
- Under the Sway desktop session, the dark-mode setting and file dialogs
  still work for GTK and Electron apps.

---

## 2. The Sway keyring daemon blocks secret-unlock prompts

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

## 3. The Sway polkit agent fights Plasma's own agent

### Current state
`modules/home/keyring-services.nix` starts
`polkit-gnome-authentication-agent-1` as a systemd user service, with no
desktop-session guard. It also starts under Plasma. Plasma already runs its
own polkit agent. Only one agent can register per desktop session. The Sway
agent's registration fails, and systemd restarts it every 3 seconds, for
the whole length of the Plasma desktop session.

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

## 4. The Sway screen-capture portal starts under Plasma and fails

### Current state
`modules/home/xdg-portal-sway.nix` starts `xdg-desktop-portal-wlr` as a
systemd user service, with no desktop-session guard. Under Plasma, the
service fails to reach an active state and hits the systemd restart limit.
The unit stays in a `failed` state for the rest of the desktop session.

The service currently fails with a wrong-display error. Item 1 of this
document may explain or remove that specific error. The deeper problem
stays regardless of item 1: this service has no reason to start at all
under a desktop session that does not use Sway or wlroots.

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

## 5. Global GTK and cursor theme variables override Plasma's own theme

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
replaces the single item 5 with two sub-items, 5a and 5b, that carry the
corrected, resolvable outcome.

### 5a. `GTK_THEME`

`home.nix`'s `gtk.enable` option writes `gtk-theme-name=Materia-dark`
directly into the home-manager-managed `~/.config/gtk-3.0/settings.ini` and
`~/.config/gtk-4.0/settings.ini`. Those files carry no session scoping, so
removing the `GTK_THEME` env var does not hand Plasma its Breeze GTK theme;
GTK apps under Plasma still read `Materia-dark` from `settings.ini`
regardless.

**Decision:** accept this. Remove `GTK_THEME` from the global session
variables anyway — it is still correct and low-risk, because it stops the
env var from overriding any per-app or Plasma-side choice, and
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

### 5b. `XCURSOR_THEME`

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
item — one consistent cursor under Plasma — but not the original literal
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

## 6. Two Bluetooth tray applets start at the same time under Plasma

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

## 7. Plasma's GTK-theme sync already leaked Breeze colors into Sway

### Current state
Plasma's GTK-theme sync tool, `kde-gtk-config`, wrote two files that
home-manager does not manage: `~/.config/gtk-3.0/gtk.css` and
`~/.config/gtk-4.0/colors.css`. The GTK3 file imports a Breeze color file.
Every GTK3 app that reads this file gets Breeze colors instead of the
`Materia-dark` color set, and this already happens under the Sway desktop
session too, because the file is not tied to either session.

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

---

## 8. Plasma settings pages can overwrite home-manager-managed theme files

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

## 9. A stale, hand-written kanshi unit hardcodes the wrong display name

### Current state
`~/.config/systemd/user/kanshi.service` is a hand-written file, not a
home-manager symlink, dated to the same era as the files in item 1. It
hardcodes `WAYLAND_DISPLAY=wayland-1` and a `PATH` value that does not
match this repository's nix-managed `PATH`. The unit targets
`sway-session.target` and stays inactive today, because `sway-startup.nix`
starts `kanshi` through a direct command instead of through this unit.

This unit causes no failure today, under either desktop session, because
it never runs. It stays a fragile piece of leftover configuration: a
future change that activates `sway-session.target`-linked units would hit
the same wrong-display problem as item 1.

### Desired outcome
No unmanaged, hand-written kanshi unit exists on disk. `kanshi` keeps
starting the way it starts today, through the direct command in
`sway-startup.nix`.

### Advantage
- Removes a leftover file that could cause a wrong-display failure if a
  future change ever activates it.
- Leaves one clear, nix-managed path for starting `kanshi`.

### Acceptance criteria
- `~/.config/systemd/user/kanshi.service` does not exist as a hand-written
  file.
- Under Sway, `kanshi` still applies its output profile on startup.

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

### Desired outcome
A sandboxed app can ask for a secret through the portal and reach Plasma's
`ksecretd` secret service.

### Advantage
- Gives a sandboxed app the same secret-storage path a regular desktop app
  already has under Plasma.

### Acceptance criteria
- A Flatpak app can request a secret through the portal and get a response
  from `ksecretd` under Plasma.
