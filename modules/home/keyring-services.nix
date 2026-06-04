# gnome-keyring, gpg-agent, and PolKit authentication agent
#
# Bundles the three secret/auth helpers that every host needs identically:
# gnome-keyring (pkcs11 + secrets), gpg-agent with a 1-year cache and
# pinentry-gnome3, and the GNOME PolKit authentication agent as a user
# systemd unit tied to graphical-session.target.
#
# Options:
#   keyring-services.enable - Enable keyring + gpg-agent + polkit agent
#
# Example usage:
#   keyring-services.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.keyring-services;
in
{
  options.keyring-services = {
    enable = lib.mkEnableOption "gnome-keyring, gpg-agent, and PolKit agent";
  };

  config = lib.mkIf cfg.enable {
    services.gnome-keyring = {
      enable = true;
      components = [
        "pkcs11"
        "secrets"
      ];
    };

    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 31536000; # 1 year
      maxCacheTtl = 31536000;
      pinentry.package = pkgs.pinentry-gnome3;
    };

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "GNOME Polkit Authentication Agent";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
