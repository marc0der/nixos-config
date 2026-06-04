# Nix daemon settings
#
# Turns on flakes + the new CLI and registers the numtide binary cache as an
# additional substituter. Centralised here so adding a new cache is a single
# line, not a hunt through configuration.nix.
#
# Options:
#   nix-settings.enable - Enable flakes + numtide substituter
#
# Example usage:
#   nix-settings.enable = true;
{
  config,
  lib,
  ...
}:

let
  cfg = config.nix-settings;
in
{
  options.nix-settings = {
    enable = lib.mkEnableOption "flakes + numtide substituter";
  };

  config = lib.mkIf cfg.enable {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nix.settings.extra-substituters = [ "https://cache.numtide.com" ];
    nix.settings.extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };
}
