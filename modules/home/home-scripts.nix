# Home Scripts Module
#
# Manages installation of shared utility scripts to ~/bin
#
# Options:
#   home-scripts.enable - Enable home scripts installation (default: false)

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
