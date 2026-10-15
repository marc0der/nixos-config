# Static dotfile assets (gnupg, icons, claude)
#
# Wires the per-user dotfiles that this repo carries verbatim outside of any
# home-manager program module: gpg.conf, icon overrides, and the
# Claude/MCP/skill assets under `claude/`. Paths are repo-relative so the
# `source` references work from the flake root.
#
# Options:
#   local.static-assets.enable - Install gnupg/icons/claude dotfiles
#
# Example usage:
#   local.static-assets.enable = true;
{
  config,
  lib,
  ...
}:

let
  cfg = config.local.static-assets;
in
{
  options.local.static-assets = {
    enable = lib.mkEnableOption "static dotfile assets (gnupg, icons, claude)";
  };

  config = lib.mkIf cfg.enable {
    home.file = {
      ".gnupg/gpg.conf".source = ../../gnupg/gpg.conf;
      ".config/playwright-mcp/config.json".source = ../../claude/playwright-mcp/config.json;
      ".local/share/icons/chatgpt.png".source = ../../icons/chatgpt.png;
      ".local/share/icons/claude-desktop.png".source = ../../icons/claude-desktop.png;
      ".claude/skills/adversarial-review/SKILL.md".source =
        ../../claude/skills/adversarial-review/SKILL.md;
      ".claude/skills/commit/SKILL.md".source = ../../claude/skills/commit/SKILL.md;
      ".claude/skills/metaprompt/SKILL.md".source = ../../claude/skills/metaprompt/SKILL.md;
      ".claude/skills/grill-with-docs".source = ../../claude/skills/grill-with-docs;
      ".claude/skills/grill-me/SKILL.md".source = ../../claude/skills/grill-me/SKILL.md;
      ".claude/skills/to-prd/SKILL.md".source = ../../claude/skills/to-prd/SKILL.md;
      ".claude/settings.json".source = ../../claude/settings.json;
      ".claude/meterstick-command.sh" = {
        source = ../../claude/meterstick.sh;
        executable = true;
      };
      ".claude/meterstick-config.json".source = ../../claude/meterstick-config.json;
      ".claude/claude_usage_oauth.py" = {
        source = ../../claude/claude_usage_oauth.py;
        executable = true;
      };
    };
  };
}
