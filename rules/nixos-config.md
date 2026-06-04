# NixOS Configuration Rules

Rules governing how this flake-based NixOS + home-manager configuration is written, structured, and changed. Covers file layout, module conventions, code style, and the build/commit workflow.

## Context

_Applies to:_ All `.nix` files in this repository (system configs, home-manager configs, modules, profiles, host overrides) and the build workflow around them.
_Level:_ Tactical/Operational
_Audience:_ Anyone (human or LLM) editing this NixOS configuration.

## Core Principles

1. _Modular by machine and concern:_ Configuration is split into reusable modules, profiles, and per-host overrides rather than monolithic files. Composition happens in `flake.nix`, not via scattered `imports`.
2. _Never commit broken builds:_ A change is only complete once it builds. Stage, build, verify, then commit.
3. _Reproducible and secret-free:_ The Nix store is world-readable. Configs hold no plaintext secrets and depend only on declared flake inputs.

## Rules

### Must Have (Critical)

- _RULE-001:_ Stage new files in git (`git add`) BEFORE running any rebuild. Flakes only see tracked files; an untracked new module is invisible to the build.
- _RULE-002:_ Follow the workflow in order: (1) stage files, (2) run the rebuild to verify, (3) only commit if the build succeeded. Never commit before a successful build.
- _RULE-003:_ Add every new module to `flake.nix` in the appropriate `modules` list. NEVER add `imports = [ ... ]` directly inside configuration files to pull in modules.
- _RULE-004:_ Put system-level config in `configuration.nix` files and user-level config in `home.nix` files. Do not mix the two layers.
- _RULE-005:_ No plaintext secrets in any `.nix` file. Use a secret-management scheme; the store is world-readable.
- _RULE-006:_ Use 2-space indentation and run `nix fmt` (nixfmt 1.x, RFC 166) before committing.
- _RULE-007:_ Use the `/commit` skill for commits. Only fall back to direct git (conventional-commit style) if the skill is unavailable.

### Should Have (Important)

- _RULE-101:_ Build with the provided convenience scripts: `nix-rebuild-home`, `nix-rebuild-system`, `nix-rebuild-all`, `nix-upgrade-all`. They handle `--impure`, `--no-warn-dirty`, etc. Don't hand-roll raw `nixos-rebuild` invocations.
- _RULE-102:_ Organize by machine and concern: shared base in the root (`configuration.nix`, `home.nix`), per-host overrides in `hosts/<name>/`, reusable system modules in `modules/system/`, home modules in `modules/home/`, optional feature bundles in `profiles/`, cross-host home fragments in `shared/`.
  - _Contract for `shared/` vs `modules/home/`:_ `shared/` modules are imported unconditionally by every host and expose **no** options — they are always on. `modules/home/` modules are **opt-in via an `enable` flag** (or equivalent option) and are turned on from the relevant `home.nix` (root or per-host). If a module has no option, it belongs in `shared/`; if it has one, it belongs in `modules/home/`. Non-`.nix` assets (powerline themes, shell scripts, etc.) live beside the module that consumes them, in whichever of the two directories that module lives in (e.g. `shared/powerline/` beside `shared/zsh.nix`, `modules/home/scripts/` beside `modules/home/home-scripts.nix`).
- _RULE-103:_ Keep modules single-purpose and named for what they configure (e.g. `hyprland-rules.nix`, `gtk-theme.nix`). Prefer many small focused modules over large catch-alls.
- _RULE-104:_ Prefer standalone script files over inline scripts embedded in Nix. When changing an existing script, migrate it to its own file rather than rewriting it inline.
- _RULE-105:_ Ask for confirmation before renaming, moving, or restructuring directories. Prefer small, reviewable changes.
- _RULE-106:_ Don't declare a fix working until the user has tested and confirmed it. After changes, ask the user to test and report back.

### Could Have (Preferred)

- _RULE-201:_ Use `lib.mkDefault` (priority 1000) for overridable defaults and `lib.mkForce` (priority 50) only when an override genuinely must win.
- _RULE-202:_ Keep both hosts (xenomorph, neomorph) in sync by hoisting shared config into `shared/` or `modules/` rather than duplicating per host.
- _RULE-203:_ Pin and reference inputs through `flake.nix` (e.g. `unstable`, `rustToolchain`) via `extraSpecialArgs`; avoid ad-hoc channel references inside modules.

## Patterns & Anti-Patterns

### ✅ Do This

Wire a new module into the host's module list in `flake.nix`:

```nix
# flake.nix -> nixosConfigurations.xenomorph.modules
modules = [
  ./configuration.nix
  ./modules/system/hyprland.nix
  ./modules/system/tailscale.nix   # new module added here
];
```

### ❌ Don't Do This

Import a module from inside another config file:

```nix
# configuration.nix -- WRONG: bypasses flake.nix composition
imports = [ ./modules/system/tailscale.nix ];
```

## Comment Style

Two-tier approach based on file type.

_Configuration files_ (`configuration.nix`, `hosts/*/configuration.nix`, `home.nix`): simple one-line inline comments above blocks, format `# Category` or `# Category: specific detail`.

_Module files_ (`modules/`, `profiles/`): structured header at top of file with description, `# Options:`, and `# Example usage:` sections.

_Discipline:_ Inline comments are ONE line. Comment WHAT a block is, not WHY or HOW. Match the comment density of surrounding code. Rationale belongs in the commit message or module header, not inline. No em dashes.

## Decision Framework

_When rules conflict:_

1. Build safety wins: never commit something that does not build (RULE-002).
2. Composition in `flake.nix` wins over local `imports` (RULE-003).
3. Layer separation (system vs home) wins over convenience.

_When facing edge cases:_

- New config that doesn't fit an existing module? Create a new single-purpose module and add it to `flake.nix`.
- Config shared across hosts? Move it to `shared/` or `modules/`, don't duplicate.
- Host-specific tweak? Put it under `hosts/<name>/`.

## Quality Gates

- _Automated checks:_ `nix fmt` passes; the relevant `nix-rebuild-*` command completes successfully.
- _Code review focus:_ New files staged in git; modules registered in `flake.nix` (not inline-imported); correct system/home layer; comment discipline.
- _Testing requirements:_ Rebuild succeeds and the user has tested and confirmed the behavior before commit.

## References

- [NixOS & Flakes Book - Modularize](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/modularize-the-configuration) - Guide to splitting and structuring configs
- [nix-starter-configs](https://github.com/Misterio77/nix-starter-configs) - Documented host/user layout templates
- [NixOS system configuration (wiki)](https://wiki.nixos.org/wiki/NixOS_system_configuration) - Module system reference
- [Flakes (wiki)](https://wiki.nixos.org/wiki/Flakes) - Flake mechanics and the git-staging caveat

---

## TL;DR

_Key Principles:_

- Modular by machine and concern; compose modules in `flake.nix`.
- Never commit a config that hasn't built successfully.
- No secrets in the store; depend only on declared flake inputs.

_Critical Rules:_

- Always `git add` new files before rebuilding.
- Always register modules in `flake.nix`; never inline-import them.
- Always `nix fmt`, build, and have the user confirm before committing via `/commit`.

_Quick Decision Guide:_ When in doubt: keep it modular, build before you commit, and add new modules to `flake.nix`, not to `imports`.
