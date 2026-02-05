# NixOS Configuration Assistant Guide

## Important Notes
- New files must be staged with `git add <file>` before home-manager/nixos-rebuild can recognize them
- Always follow this workflow:
  1. Stage necessary files with git
  2. Run home-manager/nixos-rebuild to verify changes work
  3. Only commit to git with `/commit` skill if the build was successful
- This ensures we don't commit broken configurations

## Build Commands
- System rebuild: `nix-rebuild-system` (replaces `sudo nixos-rebuild switch --flake .`)
- Home manager update: `nix-rebuild-home` (replaces `home-manager switch --flake .`)
- Rebuild all without upgrade: `nix-rebuild-all` (rebuilds both system and home without updating flake inputs)
- Update and upgrade all: `nix-upgrade-all` (updates flake inputs and upgrades both system and home)

These convenience scripts are on the PATH and handle all necessary flags like `--impure` and `--no-warn-dirty`.

### Automated vs Manual Rebuilds
- **Home manager changes**: ALWAYS run `nix-rebuild-home` automatically after making changes. Do NOT ask the user - just run it immediately. No sudo required.
- **System changes**: Ask user to run `nix-rebuild-system` or `nix-rebuild-all` (requires sudo) 

## Reporting Changes
- Changes reported automatically during activation
- Manual check: `nvd diff /run/current-system /nix/var/nix/profiles/system`

## Code Style Guidelines
- Use 2-space indentation in all Nix files
- Format with `nixfmt` before committing
- Keep comments short and concise
- Organize configurations modularly by machine (xenomorph, neomorph)
- Use explicit variable naming
- Follow machine-specific configurations in separate directories
- Keep system configs in configuration.nix files
- Keep user configs in home.nix files
- NEVER add imports directly in configuration files; always add modules to flake.nix

### Comment Style
Two-tier approach based on file type:

**Configuration files** (`configuration.nix`, `hosts/*/configuration.nix`, `home.nix`):
- Use simple inline comments above configuration blocks
- Format: `# Category` or `# Category: specific detail`
- Examples:
  ```nix
  # Networking
  # Kernel modules: SCSI generic support
  # Power management: Suspend even when plugged in
  ```

**Module files** (`modules/`, `profiles/`):
- Use structured documentation headers at top of file
- Include: module description, features/options, example usage
- Format with section headers using colons (`# Options:`, `# Example usage:`)
- Example:
  ```nix
  # Module Name
  #
  # Brief description of module purpose.
  #
  # Options:
  #   option.name - Description (default: value)
  #
  # Example usage:
  #   option.name = value;
  ```

## Git Commits
- ALWAYS use the `/commit` skill
- Do not use a task to commit to git

## Repository Structure
- Shared base configuration in root directory
- Machine-specific configs in named subdirectories
- Desktop entries (.desktop) organized by machine
- Flake-based repository using NixOS 25.11

## Assistant Behavior
- Always ask for confirmation before renaming, moving, or restructuring directories
- Never commit to git until everything is working and tested
- Use smaller changes when possible for easier review
- Prefer standalone script files over inline scripts in Nix files
- Migrate scripts to their own files rather than rewriting their functionality
- Never declare victory or confirm a fix is working until the user has tested and confirmed it works
- After making changes, ask the user to test and report back rather than assuming success
