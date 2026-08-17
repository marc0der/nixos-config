# Kanshi: Nix-Managed Systemd Unit Specification

Status: proposed
Scope: home-manager configuration for the `marco@neomorph` user. Corrects and
extends item 9 of [plasma-sway-remnants.md](plasma-sway-remnants.md).

## Why this document exists

Item 9 of `plasma-sway-remnants.md` states that
`~/.config/systemd/user/kanshi.service` "stays inactive today, because
`sway-startup.nix` starts `kanshi` through a direct command instead of through
this unit". A check against the repository and the live system shows this
statement is wrong on both counts:

- `modules/home/sway-startup.nix` contains
  `systemctl --user restart kanshi.service`. It starts kanshi *through the
  unit*, not through a direct command.
- `modules/home/kanshi.nix` writes only `~/.config/kanshi/config`. It declares
  no systemd unit, and no `services.kanshi` option is set anywhere in the
  repository.

The hand-written file is therefore the only `kanshi.service` on disk. Deleting
it, as item 9 asks, stops kanshi from starting under the Sway desktop session
and breaks output profile switching on `neomorph`.

Item 9's desired outcome stays correct. The route to it needs one extra step
first: a nix-managed unit must replace the hand-written one before the
hand-written one is deleted.

## Current state

`~/.config/systemd/user/kanshi.service` is a plain file, dated March 2025:

```
BindsTo=sway-session.target
ExecStart=/usr/bin/env WAYLAND_DISPLAY=wayland-1 kanshi
Environment=PATH=%h/.nix-profile/bin:/usr/bin:/bin
WantedBy=sway-session.target
```

Three problems:

- `WAYLAND_DISPLAY=wayland-1` is hardcoded, the same wrong-display pattern as
  item 1 of `plasma-sway-remnants.md`.
- `PATH` names `/usr/bin` and `/bin`, which do not exist on NixOS, and resolves
  `kanshi` through `~/.nix-profile/bin` rather than through the nix store.
- The file is unmanaged, so no rebuild can repair or replace it.

The unit is inactive under the current Plasma desktop session, because
`sway-session.target` is inactive. That is correct behaviour and must be kept.

## Desired outcome

`kanshi` starts under Sway through a nix-managed systemd user unit. The unit
resolves the kanshi binary from the nix store, inherits `WAYLAND_DISPLAY` from
the session rather than hardcoding it, and stays bound to
`sway-session.target` so it never starts under Plasma. No hand-written
`kanshi.service` remains on disk.

## Advantage

- Removes the last hardcoded `wayland-1` value from the user's systemd tree.
- Puts kanshi on the same declarative footing as every other user service in
  this repository.
- Keeps `sway-startup.nix` working unchanged: the same
  `systemctl --user restart kanshi.service` command drives the new unit.

## Acceptance criteria

- `~/.config/systemd/user/kanshi.service` is a symlink into the nix store, not
  a hand-written file.
- The unit's `ExecStart` names a `/nix/store` path for the kanshi binary.
- The unit sets no `WAYLAND_DISPLAY` value.
- Under Sway, `systemctl --user is-active kanshi.service` reports `active`, and
  kanshi applies its output profile on startup and on monitor hotplug.
- Under Plasma, `kanshi.service` is inactive and does not appear as failed.
- `modules/home/sway-startup.nix` needs no change.
