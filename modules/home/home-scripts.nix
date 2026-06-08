# Home Scripts Module
#
# Installs shared utility shell scripts (volume-helper, workspace-arrange,
# screenshot, etc.) from `modules/home/scripts/` into ~/bin with the
# executable bit set. Currently enabled only on hosts that need them
# (see `hosts/*/home.nix`).
#
# Options:
#   local.home-scripts.enable - Enable home scripts installation (default: false)
#
# Example usage:
#   local.home-scripts.enable = true;

{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.local.home-scripts;
in
{
  options.local.home-scripts = {
    enable = mkEnableOption "Home scripts installation";
  };

  config = mkIf cfg.enable {
    home.file = {
      "bin/volume-helper" = {
        source = ./scripts/volume-helper.sh;
        executable = true;
      };
      "bin/arrange-workspace1" = {
        source = ./scripts/arrange-workspace1.sh;
        executable = true;
      };
    };
  };
}
