---
name: host-parity
description: Check whether xenomorph and neomorph have drifted apart, and propose hoisting duplicated config into the shared module lists. Advisory only, makes no changes without approval. Use when the user asks about host drift, duplication between hosts, or keeping the two machines in sync.
---

# Host parity check

RULE-202 says shared config belongs in `commonSystemModules`, `commonHomeModules`
or `shared/`, not duplicated per host. Duplication is how a module gets added to
one machine and forgotten on the other.

## 1. Find the drift

```bash
bin/nix-host-parity
```

Exits non-zero when a module appears in every host's list but not in the
corresponding common list. It also prints what is genuinely host-only, which is
the useful context for judging the duplicates.

## 2. Judge each duplicate, do not bulk-hoist

A module in both lists is a *candidate*, not automatically a mistake. Before
proposing a hoist, check whether it is really unconditional:

- Read the module. If it exposes an `enable` flag, hoisting it is safe because
  each host still opts in from its own `home.nix` or `configuration.nix`.
- If it has no option and is always on, confirm both hosts genuinely want it.
- Flake input modules such as `inputs.agenix.nixosModules.default` are pure
  wiring and hoist cleanly.

Host-only entries are usually correct: compositors, hardware configs and
host profiles are supposed to differ. Do not propose collapsing Hyprland and
Sway modules.

## 3. Propose, then confirm

Show the user which entries you want to hoist and why. Moving entries between
module lists restructures `flake.nix`, so get explicit approval first (RULE-105).

## 4. Prove it is a no-op

A hoist should change *where* a module is listed, not what gets built. Per
CLAUDE.md, prove that with the derivation path before and after:

```bash
nix path-info --derivation "$PWD#nixosConfigurations.xenomorph.config.system.build.toplevel" --impure
```

Capture it for both hosts before the edit and again after. Identical hashes prove
byte-identical output. A changed hash means the hoist was not neutral, so diff
the realised build with `nvd diff` and explain the difference before going any
further.

Then follow the normal workflow: `git add`, `bin/nix-build-check`, and only
commit via `/commit` once the user has confirmed (RULE-002, RULE-106).

## Related

`specs/improvements.md` §1 proposed deduplicating the home module lists and that
is already done, which is why the home layer is usually clean. The system layer
was not part of that work.
