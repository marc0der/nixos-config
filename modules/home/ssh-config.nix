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
      enableDefaultConfig = false;

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
        ForwardX11 yes
        ForwardX11Trusted yes
      '';
    };

    # Force overwrite existing SSH config
    home.file.".ssh/config".force = true;

    # TODO: Replace this workaround when home-manager adds native support
    # See: https://github.com/nix-community/home-manager/issues/3090
    # Copy SSH config with proper permissions instead of symlinking.
    # Some tools (like Vorta) require 600 permissions and reject symlinks to read-only nix store files.
    home.activation.copySshConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      sshConfig="${config.home.file.".ssh/config".source}"
      if [ -e "$sshConfig" ]; then
        $DRY_RUN_CMD rm -f ~/.ssh/config
        $DRY_RUN_CMD cp "$sshConfig" ~/.ssh/config
        $DRY_RUN_CMD chmod 600 ~/.ssh/config
      fi
    '';
  };
}
