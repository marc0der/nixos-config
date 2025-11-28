# SSH Configuration Module
#
# Manages SSH client configuration via home-manager.
# Private keys remain in ~/.ssh/ and are managed outside of Nix.
#
# Usage:
#   ssh-config.enable = true;

{ config, lib, ... }:

with lib;

{
  options.ssh-config = {
    enable = mkEnableOption "SSH client configuration";
  };

  config = mkIf config.ssh-config.enable {
    programs.ssh = {
      enable = true;

      # Include configs from ~/.ssh/config.d/
      includes = [
        "~/.ssh/config.d/*"
      ];

      # Common SSH configuration
      matchBlocks = {
        # GitHub
        "github.com" = {
          identityFile = "~/.ssh/id_rsa";
          user = "git";
        };

        # Default configuration for all hosts
        "*" = {
          identityFile = "~/.ssh/id_rsa";
          serverAliveInterval = 60;
          serverAliveCountMax = 3;
        };
      };

      # Additional SSH client options
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };
  };
}
