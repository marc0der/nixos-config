---
name: purge
description: Reclaim disk space by deleting old NixOS, home-manager and nix-env generations, then collecting the store. Always previews what would go first, and retains the newest generation older than the active one in each profile so a rollback target survives. Use when /nix is filling up or the user asks to clean up generations.
argument-hint: "[keep-days] (default 7)"
---

# Purge old generations

Deleting generations is irreversible: once a generation is gone, the switch it
represents cannot be rolled back to. So preview first, always.

`nix-purge` retains the newest generation older than the active one in each
profile, even when it is older than the cutoff, so a purge leaves a rollback
target behind. It does not invent one: a profile whose active generation is its
oldest still has none.

## 1. Preview

```bash
bin/nix-purge "${ARGUMENTS:-7}" --dry-run
```

The dry run needs no privileges and deletes nothing. It prints, per profile,
which generations would go and which is retained as the rollback target.

Report to the user:

- how many generations would be deleted per profile
- which generation each profile keeps as its rollback target
- any profile reporting no generation older than the active one, which means no
  rollback target exists there yet

## 2. Check what is actually pinning the store

Generations are often not the reason `/nix` is large. The dry run ends with
`Store paths still pinned by other GC roots`. Entries there survive a purge
regardless of generation age, so if that list is long, deleting generations will
free less than the user expects. Say so before they run it.

`bin/nix-doctor` also reports `/nix` usage and any stale `result` symlinks in the
repo root, which are a common accidental pin.

## 3. Confirm, then run

Ask before deleting. Deletion is irreversible and `nix store gc` needs root, so
per CLAUDE.md hand the user the command rather than running it:

```
! bin/nix-purge <keep-days>
```

Without `--dry-run` it requires passwordless sudo for `nix` and `nix-env`; the
script fails fast with a clear message if that is missing rather than blocking on
a password prompt.

## 4. Report

The script prints the space freed. Confirm the rollback targets survived:

```bash
bin/nix-generations
```

## Choosing keep-days

The default is 7. That is only meaningful if the user switches often; if they
rebuild rarely, every generation ages out and the profile falls back to keeping
just the one rollback target. Suggest a larger window such as `nix-purge 30` when
the user wants a real rollback history rather than a single fallback.
