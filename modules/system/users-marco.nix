# Marco user account
#
# Declares the marco normal user with the groups required by the rest of the
# config (docker, networkmanager, input, dialout, wheel, sandbox) and pins the
# sandbox group to gid 1000 so it matches the same id across hosts.
#
# Options:
#   local.users-marco.enable - Create the marco user + sandbox group
#   local.users-marco.admin  - wheel + passwordless rebuild sudo (default: true)
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

    admin = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether marco is in wheel";
    };
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
      ]
      ++ lib.optional cfg.admin "wheel";
      shell = pkgs.zsh;
      packages = [ ];
    };

    users.groups.sandbox.gid = 1000;

    # Passwordless rebuild/purge sudo
    security.sudo.extraRules = lib.mkIf cfg.admin [
      {
        users = [ "marco" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = [
              "NOPASSWD"
              "SETENV"
            ];
          }
          {
            command = "/run/current-system/sw/bin/nix";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/nix-env";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
