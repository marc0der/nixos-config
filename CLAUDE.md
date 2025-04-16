# NixOS Configuration Assistant Guide

## Important Notes
- New files must be staged with `git add <file>` before home-manager/nixos-rebuild can recognize them
- Always follow this workflow:
  1. Stage necessary files with git
  2. Run home-manager/nixos-rebuild to verify changes work
  3. Only commit to git if the build was successful
- This ensures we don't commit broken configurations

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