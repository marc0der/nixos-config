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
- Format with `nixfmt` before every git commit
- Organize configurations modularly by machine (xenomorph, neomorph)
- Use explicit variable naming
- Follow machine-specific configurations in separate directories
- Keep system configs in configuration.nix files
- Keep user configs in home.nix files

## Git Commit Style
- Use specific, concise imperative statements:
  - "Add user authentication module"
  - "Fix login validation bug"
  - "Update API documentation"
  - "Refactor data processing pipeline"
  - "Remove deprecated methods"
- No lengthy descriptions in commit body
- Make small, incremental commits after each change
- Include "Co-Authored-By: Claude <noreply@anthropic.com>" in commits
- Exclude "🤖 Generated with [Claude Code](https://claude.ai/code)"
- Add standard prefixes such as `fix:`, `docs:`, `chore`, `feature`, etc to each commit
- Remember to run `nixfmt` on all files before you commit to git!

## Repository Structure
- Shared base configuration in root directory
- Machine-specific configs in named subdirectories
- Desktop entries (.desktop) organized by machine
- Flake-based repository using NixOS 24.11
