---
name: doctor
description: Health-check this NixOS configuration. Reports untracked files invisible to the flake, formatting drift, failed systemd units, rollback availability, store usage and stale flake inputs. Use when something feels off, before an upgrade, or when the user asks to check the config.
---

# Configuration health check

```bash
bin/nix-doctor
```

Read-only and unprivileged. Exits non-zero if any critical check failed.

## Interpreting the output

Do not just relay the script's output. For each `FAIL`, say what it breaks and
offer the fix:

**Untracked `.nix` or `bin/` files** (RULE-001). The flake cannot see untracked
files, so the file is invisible to every build and the user may be debugging a
module that was never evaluated. Fix: `git add` the file, then rebuild.

**Formatting drift** (RULE-006). Fix: `nix fmt`. Do this before committing, not
after.

**Failed systemd units.** The script names the unit and the journal command.
Privileged journals are the user's to run, so hand them the command:
`! journalctl -u <unit> -n 50`. Do not run `sudo journalctl` yourself.

**One system generation.** A bad switch has no way back. `nix-purge` retains the
newest generation older than the active one, so this means the profile has not
been switched often enough to have accumulated one. The next switch creates a rollback target. Until
then the mitigation is `/upgrade`, which builds and diffs before switching rather
than switching blind.

**Stale inputs.** Only a warning. Suggest `/upgrade` if the user wants them
current. `agenix` and `flake-utils` are pinned old and rarely need moving, so do
not push on those specifically.

## Things the script deliberately does not check

It cannot read `/boot`, which is root-owned, so it cannot confirm how many
generations are actually bootable. If the user needs that, give them:

```
! ls /boot/loader/entries/
```

It also does not run `nix flake check` or build anything, so it is fast and safe
to run at any time. To find out whether the config actually builds, use
`bin/nix-build-check` or the `/upgrade` skill.
