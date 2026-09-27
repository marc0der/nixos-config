# NixOS Configuration

This repository contains my NixOS system configuration managed through Nix and Home Manager. NixOS provides a declarative, reproducible, and reliable approach to system configuration, where the entire system state is defined in code. By using Home Manager alongside NixOS, I can manage both system-level configurations and user environment settings in a unified, version-controlled workflow. This setup ensures consistent environments across machines, simplifies system recovery, and enables easy testing of configuration changes through atomic upgrades and rollbacks.

## Convenience Scripts

The following convenience scripts are available in the `bin/` directory:

```bash
# Apply home-manager changes
bin/nix-rebuild-home

# Apply system-level changes
bin/nix-rebuild-system

# Apply system and home-manager changes without updating flake inputs
bin/nix-rebuild-all

# Update flake inputs and upgrade both system and home-manager
bin/nix-upgrade-all

# Build system and/or home WITHOUT activating, then nvd diff against what is live
bin/nix-build-check [system|home|both]

# List system and home-manager generations with dates and versions
bin/nix-generations [system|home]

# Activate an earlier generation
bin/nix-rollback <system|home> <generation>

# Read-only health check: untracked files, fmt drift, failed units, stale inputs
bin/nix-doctor

# Report config duplicated across both hosts (RULE-202)
bin/nix-host-parity

# Print which layers need rebuilding (edited, committed but not live, or
# with --verify, whether the working tree is what is live)
bin/nix-changed-layers [--unapplied|--verify] [--explain]

# Delete old generations and collect the store (preview with --dry-run)
bin/nix-purge [KEEP_DAYS] [--dry-run]
```

These scripts will automatically be added to your `PATH`.

`nix-purge` retains the newest generation older than the active one in each
profile as a rollback target, even when it is older than `KEEP_DAYS`, so a purge
never leaves a profile with nothing to fall back to. After a rollback, the newer
generation you fled from ages out like any other. Preview any purge with
`--dry-run` first.

A profile that has only ever had one generation still has no rollback target,
since there is nothing to retain. The next switch creates one.

## Claude Code Skills

Repository-scoped skills live in `.claude/skills/` and are versioned with the
config. They orchestrate the `bin/` scripts rather than reimplementing them.

**Start with `/start`.** It is the entry point for any maintenance session: it
runs the read-only checks (`nix-doctor`, plus `nix-changed-layers` in both its
forms), reports whether the host is healthy, which layers are edited or
committed-but-not-live, how stale the inputs are and what is uncommitted, then
recommends exactly one next skill and hands off to it. It activates nothing, so
it is always safe to run first. Reach for it when you do not know which of the
skills below applies, or when you want to know what this repo needs.

| Skill | Purpose |
| --- | --- |
| `/start` | Report the state of repo and host, then route to the right skill below |
| `/rebuild` | Apply your own config edits: infer layers, build, diff, switch |
| `/upgrade` | Update inputs, show what moved, build and diff, switch only on approval |
| `/rollback` | List generations and activate an earlier one |
| `/doctor` | Health check and interpretation of the findings |
| `/host-parity` | Report and judge drift between xenomorph and neomorph |
| `/purge` | Preview and delete old generations, keeping a rollback target |
| `/wallpaper` | Repoint the wallpaper, regenerate the pywal palette, reload hyprpaper |

Cross-project skills live in `claude/skills/` instead and are installed to
`~/.claude/skills` by `modules/home/static-assets.nix`.

## Day-to-day Workflows

### The distinction that matters

Two jobs are easy to confuse, and keeping them apart is what makes a breakage
attributable:

| Job | Use | Touches `flake.lock`? |
| --- | --- | --- |
| Apply config edits you just made | `/rebuild` | No |
| Get newer packages (week to week) | `/upgrade` | **Yes** |

Never do both at once. If a config change and an input bump land in the same
switch and something breaks, there is no way to tell which one caused it.

### After editing any `.nix` file

Run `/rebuild`. It works out which layers your edits touched via
`nix-changed-layers`, stages new files, formats, builds **without activating**,
shows an `nvd diff`, and only then switches the layers that actually changed.

Staging first is not optional: flakes only see tracked files, so an untracked
module is invisible to the build and you end up debugging a file that was never
evaluated.

A `both` rebuild switches the system layer first and only then home. If the
system switch cannot complete, it stops without touching home, because a machine
with home rebuilt from HEAD and the system on an older generation is inconsistent
in a way that is invisible afterwards. A clean working tree also does not mean
there is nothing to apply, so check for commits that were never switched:

```bash
bin/nix-changed-layers --unapplied --explain
```

### Week to week, for newer packages

Run `/upgrade`. It health-checks, updates the inputs, reports which ones moved,
builds without activating, diffs, and asks before switching. It replaces
`nix-upgrade-all`, which updated and switched in one step so that the first sign
of a bad upgrade was a broken system.

`/upgrade` runs the health check itself, so there is no need to run `/doctor`
first.

### When something breaks

`/rollback` lists generations and activates an earlier one. Check that a
rollback target exists before relying on it: a profile that has only ever had
one generation has nothing to fall back to. That is the reason both `/rebuild`
and `/upgrade` build and diff before they switch.

### Housekeeping

| Skill | When |
| --- | --- |
| `/doctor` | Not on a schedule. When something feels off, or when a new file seems to be ignored by the build. Read-only and takes seconds. |
| `/purge` | When `/nix` grows. Always previews first; retains a rollback target per profile. |
| `/host-parity` | Every month or two, or after adding a system module to one host. Drift accumulates slowly. |

### Safety model

Nothing is ever activated before it has been built and diffed. `nix-build-check`
builds into a temporary directory and runs `nvd diff` against what is live, so a
broken configuration fails before it can touch the running system.

`nix-rebuild-all` and `nix-upgrade-all` do not set `set -e`: they run the
home-manager switch even after `nixos-rebuild` has failed. The skills call
`nix-rebuild-system` and `nix-rebuild-home` separately and check each exit code
for that reason.

## Repository Structure

This is a flake-based repository using **NixOS 26.05**.

```
.
├── bin/                          # Convenience scripts
├── .claude/skills/               # Repository-scoped Claude Code skills
├── claude/                       # Claude Code assets (skills, settings, MCP config, scripts) wired in via home.nix
├── gnupg/                        # GnuPG config files copied into ~/.gnupg via home.nix
├── hosts/                        # Machine-specific configurations
│   ├── neomorph/
│   │   ├── configuration.nix     # System configuration for neomorph
│   │   ├── hardware-configuration.nix
│   │   └── home.nix              # User configuration for neomorph
│   └── xenomorph/
│       ├── configuration.nix     # System configuration for xenomorph
│       ├── hardware-configuration.nix
│       └── home.nix              # User configuration for xenomorph
├── icons/                        # PNG icons installed into ~/.local/share/icons via home.nix
├── kitty/                        # Standalone kitty terminal config (not currently wired into Nix; kept for reference)
├── modules/                      # Reusable configuration modules
│   ├── home/                     # Home Manager modules (opt-in via `enable` flags)
│   └── system/                   # NixOS system modules
├── profiles/                     # Optional feature profiles
├── qt/                           # qt5ct/qt6ct theme configs copied into ~/.config via home.nix
├── rules/                        # Repository conventions and rules (e.g. nixos-config.md) read by humans and assistants
├── secrets/                      # agenix-encrypted secrets (.age) consumed by modules/system/borg-backup.nix
├── shared/                       # Home Manager fragments imported unconditionally on every host (no options)
├── specs/                        # Proposed-change specifications (e.g. improvements.md)
├── configuration.nix             # Base system configuration
├── hardware-configuration.nix    # Base hardware configuration
├── home.nix                      # Base home-manager configuration
├── flake.nix                     # Flake entry point
└── unfree-nixpkgs.nix            # Unfree packages configuration
```

### Home Manager Module Policy

Home-manager configuration is split by contract:

- **`shared/`** — imported unconditionally on every host, exposes **no** options. If a piece of home configuration should always be on for every machine, it lives here. The directory is wired into both `homeConfigurations` entries in `flake.nix` via a single shared list.
- **`modules/home/`** — **opt-in via an `enable` flag** (or equivalent option). Each host turns on what it needs from its own `hosts/<name>/home.nix`. Modules that genuinely vary per host (compositors, portals, host-specific scripts, themes with per-host variants) belong here.

Non-`.nix` assets live beside the module that consumes them (e.g. `shared/powerline/` beside `shared/zsh.nix`, `modules/home/scripts/` beside `modules/home/home-scripts.nix`). The full rule lives next to RULE-102 in [`rules/nixos-config.md`](rules/nixos-config.md).

### Key Configuration Files

- **[flake.nix](flake.nix)**: Main entry point defining system and home-manager configurations
- **[configuration.nix](configuration.nix)**: Shared base system configuration
- **[home.nix](home.nix)**: Shared base home-manager configuration
- **[hosts/neomorph/configuration.nix](hosts/neomorph/configuration.nix)**: Neomorph system config (Sway + Work)
- **[hosts/neomorph/home.nix](hosts/neomorph/home.nix)**: Neomorph user config
- **[hosts/xenomorph/configuration.nix](hosts/xenomorph/configuration.nix)**: Xenomorph system config (Hyprland + Gaming)
- **[hosts/xenomorph/home.nix](hosts/xenomorph/home.nix)**: Xenomorph user config

## Playwright MCP Setup

The Playwright MCP browser config (`~/.config/playwright-mcp/config.json`, which
points at Brave and enables the Chromium sandbox) is managed by home-manager. The
MCP server registration itself lives in the mutable `~/.claude.json` and is not in
this repo, so register it once per machine with:

```bash
claude mcp add playwright -- npx @playwright/mcp@latest --config ~/.config/playwright-mcp/config.json
```

The `--` separates Claude's flags from the subprocess command. Restart the Claude
Code session afterwards for the server to load.

## Reporting Changes

The system is configured to automatically show changes between system generations during activation.

For manual comparison of system generations:

```bash
# Compare current system with the system profile
nvd diff /run/current-system /nix/var/nix/profiles/system

# Compare any two system generations
nvd diff /nix/var/nix/profiles/system-XXX-link /nix/var/nix/profiles/system-YYY-link
```

