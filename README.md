# NixOS Configuration

This repository contains my NixOS system configuration managed through Nix and Home Manager. NixOS provides a declarative, reproducible, and reliable approach to system configuration, where the entire system state is defined in code. By using Home Manager alongside NixOS, I can manage both system-level configurations and user environment settings in a unified, version-controlled workflow. This setup ensures consistent environments across machines, simplifies system recovery, and enables easy testing of configuration changes through atomic upgrades and rollbacks.

## Convenience Scripts

The following convenience scripts are available in the `bin/` directory:

```bash
# Apply home-manager changes
bin/nix-home

# Apply system-level changes
bin/nix-system

# Update channels and upgrade both system and home-manager
bin/nix-upgrade
```

These scripts will automatically be added to your `PATH`.

## Reporting Changes

The system is configured to automatically show changes between system generations during activation.

For manual comparison of system generations:

```bash
# Compare current system with the system profile
nvd diff /run/current-system /nix/var/nix/profiles/system

# Compare any two system generations
nvd diff /nix/var/nix/profiles/system-XXX-link /nix/var/nix/profiles/system-YYY-link
```

## Repository Structure
- Shared base configuration in root directory
- Machine-specific configs in named subdirectories
- Flake-based repository using NixOS 24.11

