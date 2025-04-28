# NixOS Configuration

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

