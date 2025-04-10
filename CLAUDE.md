# NixOS Configuration Assistant Guide

## Build Commands
- System rebuild: `sudo nixos-rebuild switch --flake .`
- Home manager update: `home-manager switch --flake .`
- System upgrade: `sudo nix flake update --flake .` then `sudo nixos-rebuild --upgrade switch --flake .`
- Home manager upgrade: `nix flake update --flake .` then `home-manager switch --upgrade --flake .`

## Reporting Changes
- Check what will change: `nvd diff /run/current-system result` (after building)

## Code Style Guidelines
- Use 2-space indentation in all Nix files
- Format with `nixfmt-rfc-style` (installed in home.nix)
- Organize configurations modularly by machine (xenomorph, neomorph)
- Use explicit variable naming
- Follow machine-specific configurations in separate directories
- Keep system configs in configuration.nix files
- Keep user configs in home.nix files

## Repository Structure
- Shared base configuration in root directory
- Machine-specific configs in named subdirectories
- Desktop entries (.desktop) organized by machine
- Flake-based repository using NixOS 24.11