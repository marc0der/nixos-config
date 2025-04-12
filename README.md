# NixOS Configuration

## System Level

To apply new changes in `configuration.nix`, run the following:

```bash
sudo nixos-rebuild switch --flake .
```
To upgrade dependencies to the latest in the specified channel in `flake.nix`:

```bash
# update the channel
sudo nix flake update --flake .

# run full system upgrade
sudo nixos-rebuild --upgrade switch --flake .
```

## Home Manager

To apply changes in `home.nix`, run the following:

```bash
home-manager switch --flake .
```

Home manager upgrades happen automatically after channel updates.

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
- Desktop entries (.desktop) organized by machine
- Flake-based repository using NixOS 24.11

