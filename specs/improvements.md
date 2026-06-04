# Repository Improvements Specification

Status: proposed
Scope: structure and conventions of this NixOS flake. No behavioural changes to
the running system are required by this spec.

This document describes _what_ should change and _why_. Implementation choices
are left to whoever picks up the work, except where a constraint is explicitly
called out.

## Constraints (from `rules/nixos-config.md`)

Every item below must be carried out within the existing rules. In particular:

- Follow the build/commit workflow on each item: stage new files with `git add`
  first (RULE-001), rebuild to verify (RULE-002), and only commit after a
  successful build via the `/commit` skill (RULE-007). "Eval-equivalent" items
  (§1, §3) must be proven with a rebuild and `nvd diff` before commit.
- New or relocated modules are registered in `flake.nix`, never pulled in via an
  inline `imports = [ ... ]` (RULE-003).
- Items that move, rename, or remove files or directories (§3, §5, §6) require
  explicit user confirmation before the change is made (RULE-105). Keep changes
  small and reviewable.
- This spec must not contradict any rule. Where a rule would need to change to
  enable an item, the item is out of scope until the rule is amended first.

---

## 1. Deduplicate Home Manager module lists in `flake.nix`

### Current state
`marco@neomorph` and `marco@xenomorph` each enumerate ~20 home-manager modules.
The majority of those modules are identical between the two hosts; only the
compositor-specific modules and profiles differ.

### Desired outcome
The set of modules that every host receives is declared exactly once. Each host
entry in `flake.nix` lists only what is unique to that host.

### Advantage
- Adding a new always-on home module is a one-line change instead of two.
- Eliminates the class of bug where a module is added to one host and forgotten
  on the other.
- Makes host differences visible at a glance.

### Acceptance criteria
- No home module path appears verbatim in both host module lists.
- `flake.nix` still evaluates and both `homeConfigurations` build identically to
  before (no package or option diff).

---

## 2. Shrink the root `configuration.nix` and `home.nix`

### Current state
`configuration.nix` (347 lines) and `home.nix` (346 lines) are the two largest
files in the repository and dwarf every module. They mix unrelated concerns:
bootloader, locale, networking, kernel-module blacklists, large package lists,
shell setup, etc.

### Desired outcome
The root files contain only configuration that is genuinely shared, generic,
and small enough to read in one sitting. Anything that fits a clear theme moves
into a named module under `modules/system/` or `modules/home/` and is enabled
via an option flag in keeping with the existing module style. New modules must
be registered in the appropriate `flake.nix` module list, never pulled in via an
inline `imports = [ ... ]` (RULE-003).

### Advantage
- Easier to locate a given piece of configuration.
- Modules can be turned off per host without editing the shared file.
- Reduces the merge-conflict surface of the two most-edited files in the repo.

### Acceptance criteria
- Neither root file exceeds roughly 150 lines.
- Each extracted module follows the existing header-doc convention
  (description, Options, Example usage) defined in `CLAUDE.md`.
- No regression in evaluated configuration on either host.

---

## 3. Resolve the duplicate `hardware-configuration.nix`

### Current state
A `hardware-configuration.nix` exists at the repository root _and_ at
`hosts/<host>/hardware-configuration.nix`, and `flake.nix` imports both for each
host. Hardware configuration is by definition per-machine, so the existence of
a shared one is misleading.

### Desired outcome
Exactly one of the following is true:
- The root file is removed and its contents merged into each host's hardware
  file (if they are in fact host-specific), **or**
- The root file is renamed to reflect what it actually is (e.g. a shared
  low-level system module) and moved under `modules/system/`.

### Advantage
- Removes a naming lie. A file called `hardware-configuration.nix` should
  describe one machine's hardware.
- Aligns with the NixOS convention readers will expect.

### Acceptance criteria
- No file named `hardware-configuration.nix` exists outside `hosts/<host>/`.
- Each host still builds with the same hardware-level options as before.

---

## 4. Fix the NixOS version stated in docs

### Current state
Three different release strings disagree:
- `README.md` says "This is a flake-based repository using **NixOS 25.05**".
- `CLAUDE.md` says "Flake-based repository using NixOS 25.11".
- `flake.nix` actually pins `nixos-26.05` (and `home-manager` `release-26.05`).

### Desired outcome
Both `README.md` and `CLAUDE.md` reflect the actual pinned release.

### Advantage
- Documentation matches reality. Low effort, high signal.

### Acceptance criteria
- `README.md` and `CLAUDE.md` both state 26.05 (or whatever is currently
  pinned in `flake.nix`).

---

## 5. Define and apply a clear policy for `shared/` vs `modules/home/`

### Current state
Both directories hold home-manager modules. Some `shared/` files (`git.nix`,
`zsh.nix`, `tmux.nix`, `rust.nix`, `report.nix`) are imported by every host
unconditionally. Some `modules/home/` files (`terminal-ghostty.nix`,
`ssh-config.nix`, `desktop-common.nix`) are _also_ imported by every host
unconditionally. There is no rule that explains which directory a new module
should go in.

Note: `rules/nixos-config.md` (RULE-102) already defines `shared/` as
"cross-host home fragments" and `modules/home/` as "home modules". The policy
below is the one consistent with that existing rule and must not contradict it.

The policy must also state where non-`.nix` assets live. `shared/` currently
contains `shared/powerline/` (a p10k asset tree) and `modules/home/` contains
`modules/home/scripts/` (shell scripts), so "home modules" is not purely `.nix`
files today.

### Desired outcome
Split by contract (consistent with RULE-102): `shared/` means "imported by
every host, exposes no options"; `modules/home/` means "opt-in via an `enable`
flag". Modules are moved to the directory that matches the contract they
actually fulfil. This contract is then applied consistently across the repo.

Non-`.nix` assets stay with the module that consumes them (e.g.
`shared/powerline/` beside the module that references it, `modules/home/scripts/`
beside the home modules that install them).

### Advantage
- New contributors (and the author six months later) know where to put things.
- Removes the ambiguity that currently lets either directory grow arbitrarily.

### Acceptance criteria
- The chosen policy is documented in `README.md` or `CLAUDE.md` in one short
  paragraph.
- Every existing module is in the directory that matches the policy.

---

## 6. Document or remove unreferenced top-level directories

### Current state
The `kitty/` directory (containing `kitty.conf`) exists at the repository root,
is not referenced by any `.nix` file, and is not mentioned in `README.md`. Its
purpose is not discoverable from the repository alone.

For contrast, `gnupg/`, `icons/`, `qt/`, and `claude/` are _also_ absent from
the `README.md` tree, but each is referenced from `home.nix` via `home.file` /
`xdg` (so it is at least discoverable by grepping the Nix sources). The newer
`rules/` and `specs/` directories are likewise missing from the README tree.

### Desired outcome
For each undocumented top-level directory (`kitty/`, plus the README-tree gaps
for `gnupg/`, `icons/`, `qt/`, `claude/`, `rules/`, `specs/`), exactly one of:
- It is referenced from a Nix module (e.g. via `home.file` or
  `xdg.configFile`), and that reference is easy to find; **or**
- It is described in the README's repository-structure section in one line;
  **or**
- It is removed.

### Advantage
- A new reader can tell from the top-level listing what every directory is
  for. No "what does this do?" archaeology.

### Acceptance criteria
- The repository tree in `README.md` lists every top-level directory that
  remains.
- No directory at the root is both unreferenced and undocumented.

---

## 7. Make the Sway and Hyprland module layouts symmetric

### Current state
Sway is split into four home modules: `sway-desktop.nix`, `sway-config.nix`,
`sway-rules.nix`, `sway-keybindings.nix`. Hyprland is split into four with a
different shape: `hyprland-desktop.nix`, `hyprland-config.nix`,
`hyprland-rules.nix`, `hyprland-extras.nix`. `hyprland-config.nix` is 263 lines
and contains keybindings inline; the equivalent Sway file has them extracted
into `sway-keybindings.nix`. Note, however, that `sway-config.nix` is still 272
lines even with keybindings extracted, so Sway is not a clean exemplar of the
150-line target below.

### Desired outcome
The two compositors follow the same decomposition. Specifically, Hyprland gains
a `hyprland-keybindings.nix` so that both compositors expose `desktop`,
`config`, `rules`, and `keybindings` as separate modules. What `extras` covers
should either be folded into one of the four or renamed to make its role
obvious.

### Advantage
- Easier to compare the two compositor setups side by side.
- `hyprland-config.nix` becomes small enough to read without scrolling.
- New compositor-level features have an obvious home.

### Acceptance criteria
- `modules/home/` contains a `*-keybindings.nix` for both `sway` and
  `hyprland`.
- No `*-config.nix` for either compositor exceeds roughly 150 lines. This
  requires further extraction from `sway-config.nix` (272 lines) as well as
  `hyprland-config.nix`, not just adding `hyprland-keybindings.nix`.

---

## 8. Confirm `home.stateVersion`

### Current state
`home.nix` sets `home.stateVersion = "24.11";` (and `configuration.nix` sets
`system.stateVersion = "24.11";`) while the flake tracks 26.05.
This is most likely correct — `stateVersion` is a one-time pin, not a tracking
field — but it is worth a deliberate confirmation rather than a drive-by bump.

### Desired outcome
The current value is verified as intentional. No change is made unless there is
a specific reason to change it. A short comment next to the line records the
decision.

### Advantage
- Prevents a future contributor from "fixing" the version and triggering
  surprise migrations in stateful home-manager modules.

### Acceptance criteria
- `home.stateVersion` is unchanged unless deliberately migrated.
- A one-line comment makes the intent explicit.

---

## Out of scope

The following are explicitly not part of this spec and should not be bundled
into the work:

- Behavioural changes to any host (no new packages, no new services).
- Renaming hosts or restructuring `hosts/`.
- Changes to the convenience scripts in `bin/`.
- Switching package sources between `nixpkgs` and `nixpkgs-unstable`.

---

## Suggested order of work

The items are independent, but a sensible order minimises risk:

1. §4 (README version) — trivial, no eval impact.
2. §6 (document or remove stray directories) — purely organisational.
3. §1 (dedupe flake module lists) — eval-equivalent refactor.
4. §3 (hardware-configuration cleanup) — small and self-contained.
5. §5 (shared vs modules/home policy) — document the split-by-contract policy,
   then move files to match it.
6. §2 (shrink root files) — largest diff; do after §5 so destinations are
   clear.
7. §7 (compositor symmetry) — independent of the rest.
8. §8 (stateVersion confirmation) — can be done at any time.
