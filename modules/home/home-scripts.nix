# Home Scripts Module
#
# Installs shared utility shell scripts (volume-helper, workspace-arrange,
# screenshot, etc.) from `modules/home/scripts/` into ~/bin with the
# executable bit set. Currently enabled only on hosts that need them
# (see `hosts/*/home.nix`).
#
# Options:
#   home-scripts.enable - Enable home scripts installation (default: false)
#
# Example usage:
#   home-scripts.enable = true;

{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.home-scripts;
in
{
  options.home-scripts = {
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
      "bin/kanshi-mirror" = {
        source = ./scripts/kanshi-mirror.sh;
        executable = true;
      };
    };
  };
}
