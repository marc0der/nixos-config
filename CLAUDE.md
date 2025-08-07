# NixOS Configuration Assistant Guide

## Important Notes
- New files must be staged with `git add <file>` before home-manager/nixos-rebuild can recognize them
- Always follow this workflow:
  1. Stage necessary files with git
  2. Run home-manager/nixos-rebuild to verify changes work
  3. Only commit to git if the build was successful
- This ensures we don't commit broken configurations

## Build Commands
- System rebuild: `bin/nix-system` (replaces `sudo nixos-rebuild switch --flake .`)
- Home manager update: `bin/nix-home` (replaces `home-manager switch --flake .`)
- System and home-manager upgrade: `bin/nix-upgrade` (updates channels and upgrades both)

These convenience scripts are available in the `bin/` directory and handle all necessary flags like `--impure` and environment variables like `NIXPKGS_ALLOW_UNFREE=1`.

## Reporting Changes
- Changes reported automatically during activation
- Manual check: `nvd diff /run/current-system /nix/var/nix/profiles/system`

## Code Style Guidelines
- Use 2-space indentation in all Nix files
- Format with `nixfmt` before every git commit
- Organize configurations modularly by machine (xenomorph, neomorph)
- Use explicit variable naming
- Follow machine-specific configurations in separate directories
- Keep system configs in configuration.nix files
- Keep user configs in home.nix files
- NEVER add imports directly in configuration files; always add modules to flake.nix

## Git Commits
- ALWAYS use the git-committer agent

## Repository Structure
- Shared base configuration in root directory
- Machine-specific configs in named subdirectories
- Desktop entries (.desktop) organized by machine
- Flake-based repository using NixOS 24.11

## Assistant Behavior
- Always ask for confirmation before renaming, moving, or restructuring directories
- Never commit to git until everything is working and tested
- Use smaller changes when possible for easier review
- Prefer standalone script files over inline scripts in Nix files
- Migrate scripts to their own files rather than rewriting their functionality
