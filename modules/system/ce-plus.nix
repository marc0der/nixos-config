# Cyber Essentials Plus
#
# Audit posture for CE+. Always declares a password-locked `admin` user in
# wheel; set its password with `sudo passwd admin` before enabling. When
# enabled, marco loses wheel and every sudo rule, ClamAV runs nightly plus
# on-access over Downloads, SSH is key-only and reachable via Tailscale only,
# and failed logins are throttled to at most 10 guesses per 5 minutes.
#
# Recovery (flag back to false), as marco:
#   su - admin
#   sudo nixos-rebuild switch --flake path:/home/marco/nixos --impure --no-write-lock-file
# Last resort: pick the previous generation in the systemd-boot menu.
#
# Options:
#   local.ce-plus.enable - Enforce the CE+ audit posture (default: false)
#
# Example usage:
#   local.ce-plus.enable = true;
{
  config,
  lib,
  ...
}:

let
  cfg = config.local.ce-plus;
  throttled =
    lib.genAttrs
      [
        "kde"
        "login"
        "polkit-1"
        "sddm"
        "sshd"
        "su"
        "sudo"
        "systemd-run0"
      ]
      (_: {
        failDelay = {
          enable = true;
          delay = 30000000;
        };
      });
in
{
  options.local.ce-plus = {
    enable = lib.mkEnableOption "Cyber Essentials Plus audit posture";
  };

  config = lib.mkMerge [
    {
      users.users.admin = {
        isNormalUser = true;
        description = "Administrator";
        extraGroups = [ "wheel" ];
      };
    }

    (lib.mkIf cfg.enable {
      # User access control: no admin rights for marco
      local.users-marco.admin = false;
      security.sudo.execWheelOnly = true;

      # Malware protection
      local.services.clamav-security = {
        enable = true;
        onAccessPaths = [ "/home/marco/Downloads" ];
      };

      # Firewall: SSH over Tailscale only, keys only
      services.openssh = {
        openFirewall = false;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };

      # Secure configuration: throttle password guessing
      security.pam.services = throttled;
    })
  ];
}
