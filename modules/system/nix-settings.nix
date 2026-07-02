# Nix daemon settings
#
# Turns on flakes + the new CLI and registers the numtide binary cache as an
# additional substituter. Centralised here so adding a new cache is a single
# line, not a hunt through configuration.nix.
#
# Also runs weekly garbage collection (keeping 7 days of generations) and
# auto-optimises the store so old generations cannot silently fill the disk.
#
# Options:
#   local.nix-settings.enable - Enable flakes + numtide substituter
#
# Example usage:
#   local.nix-settings.enable = true;
{
  config,
  lib,
  ...
}:

let
  cfg = config.local.nix-settings;
in
{
  options.local.nix-settings = {
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

    # Garbage collection: weekly, keep 7 days of generations
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Deduplicate identical store files
    nix.settings.auto-optimise-store = true;
  };
}
