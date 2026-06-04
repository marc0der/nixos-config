# Marco user account
#
# Declares the marco normal user with the groups required by the rest of the
# config (docker, networkmanager, input, dialout, wheel, sandbox) and pins the
# sandbox group to gid 1000 so it matches the same id across hosts.
#
# Options:
#   local.users-marco.enable - Create the marco user + sandbox group
#
# Example usage:
#   local.users-marco.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.users-marco;
in
{
  options.local.users-marco = {
    enable = lib.mkEnableOption "marco user account and sandbox group";
  };

  config = lib.mkIf cfg.enable {
    users.users.marco = {
      isNormalUser = true;
      description = "Marco Vermeulen";
      extraGroups = [
        "dialout"
        "docker"
        "input"
        "networkmanager"
        "sandbox"
        "wheel"
      ];
      shell = pkgs.zsh;
      packages = [ ];
    };

    users.groups.sandbox.gid = 1000;
  };
}
