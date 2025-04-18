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
- Channel updates: `sudo nix flake update --flake .`
- System upgrade:  `sudo nixos-rebuild --upgrade switch --flake .` after channel updates
- Home manager update: `home-manager switch --flake .`
- Home manager upgrade happens with update after channel updates

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
- NEVER commit to git until everything is working and tested

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
