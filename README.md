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

To check what will change in the system (after building):

```bash
nvd diff /run/current-system result
```

## Repository Structure
- Shared base configuration in root directory
- Machine-specific configs in named subdirectories
- Desktop entries (.desktop) organized by machine
- Flake-based repository using NixOS 24.11

