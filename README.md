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
```

These scripts will automatically be added to your `PATH`.

## Repository Structure

This is a flake-based repository using **NixOS 25.05**.

```
.
├── bin/                          # Convenience scripts
├── hosts/                        # Machine-specific configurations
│   ├── neomorph/
│   │   ├── configuration.nix     # System configuration for neomorph
│   │   ├── hardware-configuration.nix
│   │   └── home.nix              # User configuration for neomorph
│   └── xenomorph/
│       ├── configuration.nix     # System configuration for xenomorph
│       ├── hardware-configuration.nix
│       └── home.nix              # User configuration for xenomorph
├── modules/                      # Reusable configuration modules
│   ├── home/                     # Home Manager modules
│   └── system/                   # NixOS system modules
├── profiles/                     # Optional feature profiles
├── shared/                       # Shared configurations
├── configuration.nix             # Base system configuration
├── hardware-configuration.nix    # Base hardware configuration
├── home.nix                      # Base home-manager configuration
├── flake.nix                     # Flake entry point
└── unfree-nixpkgs.nix            # Unfree packages configuration
```

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

