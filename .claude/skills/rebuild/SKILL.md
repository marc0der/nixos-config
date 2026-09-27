---
name: rebuild
description: Apply config changes to this host, without touching flake inputs. Works out which layers need rebuilding (edited but not built, and committed but not live), builds and diffs, then switches system before home. Use after editing any .nix file, or when the user asks to rebuild, apply changes, or switch. For updating flake inputs use /upgrade instead.
argument-hint: "[system|home|both] (default: inferred)"
---

# Rebuild from local changes

Applies what is in the repo. It must **not** update `flake.lock`: mixing a config
change with an input bump makes a breakage impossible to attribute. If the user
wants newer packages, that is `/upgrade`.

## Never half-apply

**A `both` rebuild either applies both layers or applies neither.** Leaving the
system on an old generation while home is rebuilt from HEAD is an inconsistent
machine, and it is worse than doing nothing because it is invisible afterwards.

Therefore: **switch the system layer first and confirm it succeeded before
touching home.** The system is the base layer, so if it cannot be switched,
stopping leaves the machine consistent rather than split. Never reverse this
order, and never apply home "while we wait" for the system switch.

## 1. Work out what needs rebuilding

Two different questions, and a `both` run needs both answers:

```bash
bin/nix-changed-layers --explain              # edited but not built
bin/nix-changed-layers --unapplied --explain  # committed but not live
```

The first compares the working tree to HEAD. The second compares HEAD to the
running generation, and catches the case where nothing is edited but commits
have never been switched. A clean working tree does **not** mean there is
nothing to do.

Take the union of both. If `$ARGUMENTS` names a layer, use that and say you are
overriding the inference. If both come back empty, say so and stop.

## 2. Stage new files

```bash
git status --porcelain
```

Flakes only see tracked files, so an untracked module is invisible to the build
and the user ends up debugging a file that was never evaluated (RULE-001). Stage
any new `.nix` file with `git add` before building. `bin/nix-doctor` flags this.

## 3. Format

```bash
nix fmt
```

Required before commit by RULE-006, and cheaper now than after the build.

## 4. Build and diff both layers before switching anything

```bash
bin/nix-build-check <layer>
```

Activates nothing. If it exits non-zero, report the error and stop; do not
switch a configuration that failed to build.

Summarise the `nvd diff`: kernel or bootloader changes needing a reboot, and
removals as opposed to version bumps.

## 5. Switch, system first

```bash
nix-rebuild-system    # only if the system layer needs it
```

Invoke it **bare**, not as `./bin/nix-rebuild-system`: the scripts are on `PATH`
via `home.sessionPath`, and the permission rule matches the bare name.

CLAUDE.md authorises running this directly and `nixos-rebuild` has passwordless
sudo with `SETENV` (`configuration.nix`, `security.sudo.extraRules`), so do not
defer it to the user by default.

**If the system switch does not complete** for any reason, including a harness
permission denial:

1. **Stop. Do not run the home switch.** The machine stays consistent.
2. Tell the user plainly that nothing was applied and why.
3. Give them the one command to finish it: `! nix-rebuild-system`.
4. Only once they confirm the system is switched, come back and apply home.

Once the system switch has succeeded:

```bash
nix-rebuild-home
```

Do not use `nix-rebuild-all`: no `set -e`, so it runs the home switch even after
the system switch failed, which is the same half-applied trap.

## 6. Verify consistency, then let the user confirm

```bash
bin/nix-changed-layers --verify
```

This compares the working tree, not HEAD, to what is live, since nothing is
committed until the user confirms. It must print nothing. If it still names a
layer, the rebuild did not finish and the machine is in a split state: say so
explicitly rather than reporting success.

Then report what was applied and whether a reboot is needed. Per RULE-106 do not
declare it working; ask the user to test, and only commit via `/commit` once they
confirm (RULE-002).
