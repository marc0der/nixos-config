---
name: rollback
description: Roll back this host to an earlier NixOS system or home-manager generation. Lists generations with dates and versions, then activates the chosen one. Use when a rebuild or upgrade broke something and the user wants the previous state back.
argument-hint: "[system|home] [generation]"
---

# Roll back a generation

A rollback activates an older build. It changes nothing in the repo, so the way
to undo a rollback is to rebuild.

## 1. Show what is available

```bash
nix-generations
```

Present the candidates with their dates and NixOS versions.

If only one system generation exists, **there is nothing to roll back to**. Say
so plainly rather than offering a command that will fail. `nix-purge` retains the
newest generation older than the active one, so this state means the profile has
not been switched often enough to have one, not that a purge discarded it. In that case the options
are:

- roll back the home layer only, if the breakage is in home-manager
- `git checkout` the offending commit or `flake.lock` and rebuild forward
- boot an older generation from the systemd-boot menu, if one is still there

## 2. Confirm the target

Do not guess which generation the user wants. If `$ARGUMENTS` did not name one,
ask, using the dates to help them pick. Rolling the system back is disruptive
and hard to reverse quickly, so confirm the specific generation number before
acting.

## 3. Activate it

The home layer needs no privileges, so run it directly:

```bash
nix-rollback home <generation>
```

The system layer needs root. Per CLAUDE.md, do not invoke `sudo` yourself. Give
the user the command to run:

```
! nix-rollback system <generation>
```

The script validates that the generation exists, prints the target store path
and version, and asks for confirmation before switching.

## 4. After

Ask the user what the state looks like now. If the rollback fixed things, the
cause is in the diff between the two generations:

```bash
nvd diff /nix/var/nix/profiles/system-<old>-link /nix/var/nix/profiles/system-<new>-link
```

Use that to find the culprit before rebuilding forward. Per RULE-106, do not
declare the problem solved until the user confirms.
