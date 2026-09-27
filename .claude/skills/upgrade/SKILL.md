---
name: upgrade
description: Safely upgrade this NixOS flake. Updates flake inputs, shows which inputs moved, builds system and home WITHOUT switching, shows an nvd diff, and only then switches on approval. Use when the user asks to upgrade, update flake inputs, or run nix-upgrade-all.
argument-hint: "[system|home|both] (default both)"
---

# Safe flake upgrade

`nix-upgrade-all` updates inputs and switches in one step, so the first sign of a
bad upgrade is a broken system. This skill puts a build and a diff in front of
the switch.

Never skip a step to save time. The whole point is that nothing is activated
until the user has seen the diff.

## 1. Pre-flight

```bash
nix-doctor
```

If it reports untracked `.nix` or `bin/` files, stop and `git add` them first
(RULE-001): the flake cannot see untracked files, so the build would not reflect
them. Report a failed rollback-availability check to the user now, because it
tells them whether a bad switch can be undone.

Record the starting point so it can be named later:

```bash
nix-generations
```

## 2. Update the inputs

```bash
nix flake update --flake "$PWD"
```

No `sudo`. It writes `flake.lock` in place, which preserves ownership, and input
fetching goes through the nix-daemon. Verified on this host.

The command prints every input it moved. Summarise that for the user: which
inputs changed and how far each one jumped. If nothing moved, say so and stop
here, since there is nothing to build.

## 3. Build without switching

```bash
nix-build-check "$ARGUMENTS"
```

Defaults to `both`. This builds the system and home configurations and runs
`nvd diff` against what is live, activating nothing. If it exits non-zero the
build is broken: report the error and **do not** proceed to step 4. Offer to
revert the lockfile with `git checkout flake.lock`.

## 4. Present the diff

Summarise the `nvd diff` output rather than pasting it wholesale. Call out:

- kernel or bootloader changes, which need a reboot
- package removals, as opposed to version bumps
- anything touching a module the user changed recently

## 5. Switch, on approval only

Ask before switching. On approval, run the two layers separately so a failed
system switch cannot fall through into the home switch:

```bash
nix-rebuild-system   # skip if ARGUMENTS was "home"
nix-rebuild-home     # skip if ARGUMENTS was "system"
```

Check each exit code before running the next. Do not use `nix-rebuild-all` or
`nix-upgrade-all` here: neither sets `set -e`, so both run the home switch even
after the system switch has failed.

## 6. Report

State what was upgraded, whether a reboot is needed, and the rollback command
if something looks wrong:

```bash
nix-generations
nix-rollback system <previous-generation>
```

Per RULE-106, do not call the upgrade good. Ask the user to test and report
back, and do not commit `flake.lock` until they confirm. When they do, commit
with the `/commit` skill.
