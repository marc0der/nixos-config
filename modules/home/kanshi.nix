# Kanshi Module
#
# Declarative kanshi output configuration with dynamic projector mirroring.
# Generates ~/.config/kanshi/config and builds the mirror/unmirror helpers so
# they resolve their tools under kanshi's minimal service PATH.
#
# Options:
#   local.kanshi.enable - Enable kanshi config management (default: false)
#
# Example usage:
#   local.kanshi.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.local.kanshi;
  kanshi-mirror = pkgs.writeShellApplication {
    name = "kanshi-mirror";
    runtimeInputs = with pkgs; [
      procps
      coreutils
      sway
      jq
      wl-mirror
    ];
    text = builtins.readFile ./scripts/kanshi-mirror.sh;
  };
  kanshi-unmirror = pkgs.writeShellApplication {
    name = "kanshi-unmirror";
    runtimeInputs = with pkgs; [ procps ];
    text = builtins.readFile ./scripts/kanshi-unmirror.sh;
  };
in
{
  options.local.kanshi = {
    enable = mkEnableOption "kanshi output configuration";
  };

  config = mkIf cfg.enable {
    xdg.configFile."kanshi/config".text = ''
      profile default {
          output eDP-1 enable position 0,0 scale 1.5
          exec ${kanshi-unmirror}/bin/kanshi-unmirror
      }

      profile docked {
          output "Dell Inc. DELL U3219Q 38RYXV2" enable scale 1 position 0,0 mode 3840x2160
          output eDP-1 disable
      }

      profile dual {
          output "Dell Inc. DELL U3219Q 38RYXV2" enable scale 1 position 0,0 mode 3840x2160
          output eDP-1 position 960,2160 scale 1.5
      }

      profile misc {
          output "LG Electronics LG TV 0x01010101" enable
          output eDP-1 disable
      }

      profile forced {
          output "Dell Inc. DELL U3219Q 38RYXV2" disable
          output eDP-1 enable position 0,0 scale 1.5
      }

      profile mirror {
          output eDP-1 enable position 0,0 scale 1.5
          output * enable position 1920,0 scale 1
          exec ${kanshi-mirror}/bin/kanshi-mirror
      }
    '';
  };
}
