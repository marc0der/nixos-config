# NixOS Configuration Assistant Guide

## Rules
- Follow the rules in [rules/nixos-config.md](rules/nixos-config.md) when writing or changing any config.

## Important Notes
- New files must be staged in git before home-manager/nixos-rebuild can recognize them
- Always follow this workflow:
  1. Stage necessary files with git
  2. Run home-manager/nixos-rebuild to verify changes work
  3. Only commit to git if the build was successful
- This ensures we don't commit broken configurations

## Build Commands
- System rebuild: `nix-rebuild-system` (replaces `sudo nixos-rebuild switch --flake .`)
- Home manager update: `nix-rebuild-home` (replaces `home-manager switch --flake .`)
- Rebuild all without upgrade: `nix-rebuild-all` (rebuilds both system and home without updating flake inputs)
- Update and upgrade all: `nix-upgrade-all` (updates flake inputs and upgrades both system and home)

These convenience scripts are on the PATH and handle all necessary flags like `--impure` and `--no-warn-dirty`.

### Automated vs Manual Rebuilds
- **Home manager changes**: ALWAYS run `nix-rebuild-home` automatically after making changes. Do NOT ask the user - just run it immediately. No sudo required.
- **System changes**: Run `nix-rebuild-system` or `nix-rebuild-all` directly (sudo not required). No need to ask the user.

## Reporting Changes
- Changes reported automatically during activation
- Manual check: `nvd diff /run/current-system /nix/var/nix/profiles/system`

## Code Style Guidelines
- Use 2-space indentation in all Nix files
- Format with `nix fmt` before committing (uses `nixfmt` 1.x, RFC 166 style)
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

### Comment Discipline (avoid verbose comments)
- Inline comments are ONE line. Never write multi-line comments explaining mechanism, rationale, or edge cases inside config blocks.
- Comment WHAT a block is, not WHY or HOW it works. The code shows how.
- If you feel the need to explain why something works, that belongs in a commit message or the module's header doc — not inline.
- Match the density of surrounding comments. Don't add a comment where neighboring entries have none.
- Examples:
  ```nix
  # Bad (verbose, explains mechanism):
  # Complementary rules so whichever window opens second snaps the split;
  # the other's rule no-ops while it is the only window on the workspace.

  # Good (one line, says what):
  # Workspace 1 columns: Slack 33% (left), Brave 67% (right)
  ```

## Git Commits
- ALWAYS try to use the `/commit` skill
- Only commit with git directly _if the `/commit` skill is not available_
- Use conventional commit convention if interacting with git directly: https://www.conventionalcommits.org/en/v1.0.0/

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
