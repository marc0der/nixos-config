# Static dotfile assets (gnupg, qt, icons, claude)
#
# Wires the per-user dotfiles that this repo carries verbatim outside of any
# home-manager program module: gpg.conf, Qt 5/6 ct configs, icon overrides,
# and the Claude/MCP/skill assets under `claude/`. Paths are repo-relative
# so the `source` references work from the flake root.
#
# Options:
#   local.static-assets.enable - Install gnupg/qt/icons/claude dotfiles
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
    enable = lib.mkEnableOption "static dotfile assets (gnupg, qt, icons, claude)";
  };

  config = lib.mkIf cfg.enable {
    home.file = {
      ".gnupg/gpg.conf".source = ../../gnupg/gpg.conf;
      ".config/playwright-mcp/config.json".source = ../../claude/playwright-mcp/config.json;
      ".config/qt5ct/qt5ct.conf".source = ../../qt/qt5ct.conf;
      ".config/qt6ct/qt6ct.conf".source = ../../qt/qt6ct.conf;
      ".local/share/icons/chatgpt.png".source = ../../icons/chatgpt.png;
      ".local/share/icons/claude-desktop.png".source = ../../icons/claude-desktop.png;
      ".claude/skills/commit/SKILL.md".source = ../../claude/skills/commit/SKILL.md;
      ".claude/skills/metaprompt/SKILL.md".source = ../../claude/skills/metaprompt/SKILL.md;
      ".claude/skills/grill-with-docs".source = ../../claude/skills/grill-with-docs;
      ".claude/skills/grill-me/SKILL.md".source = ../../claude/skills/grill-me/SKILL.md;
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
