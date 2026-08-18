# gnome-keyring, gpg-agent, and PolKit authentication agent
#
# Bundles the three secret/auth helpers that every host needs identically:
# gnome-keyring (pkcs11 only, so ksecretd owns the secrets service),
# gpg-agent with a 1-year cache and pinentry-gnome3, and the GNOME PolKit
# authentication agent as a user systemd unit tied to a configurable
# session target.
#
# Options:
#   local.keyring-services.enable - Enable keyring + gpg-agent + polkit agent
#   local.keyring-services.polkitSessionTarget - Session target the PolKit agent
#     binds to (default: "graphical-session.target")
#
# Example usage:
#   local.keyring-services.enable = true;
#   local.keyring-services.polkitSessionTarget = "sway-session.target";
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.keyring-services;
in
{
  options.local.keyring-services = {
    enable = lib.mkEnableOption "gnome-keyring, gpg-agent, and PolKit agent";

    polkitSessionTarget = lib.mkOption {
      type = lib.types.str;
      default = "graphical-session.target";
      example = "sway-session.target";
      description = "Systemd user target the PolKit agent is bound to";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gnome-keyring = {
      enable = true;
      components = [ "pkcs11" ];
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
        PartOf = [ cfg.polkitSessionTarget ];
        After = [ cfg.polkitSessionTarget ];
      };
      Service = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install = {
        WantedBy = [ cfg.polkitSessionTarget ];
      };
    };
  };
}
