# gnome-keyring, gpg-agent, and PolKit authentication agent
#
# Bundles the three secret/auth helpers that every host needs identically:
# gnome-keyring (pkcs11 only, so ksecretd owns the secrets service),
# gpg-agent with a 1-year cache and pinentry-gnome3, and the GNOME PolKit
# authentication agent as a user systemd unit, which hosts whose desktop
# brings its own agent can switch off.
#
# When gpgKeygrip is set, a login-triggered service also presets that key's
# passphrase into gpg-agent from the desktop secret service (ksecretd on
# Plasma, gnome-keyring elsewhere), so the pinentry popup no longer appears
# on the first commit of the day. Store the passphrase once via:
#   secret-tool store --label="GPG key passphrase" service gpg-agent keygrip <keygrip>
#
# Options:
#   local.keyring-services.enable - Enable keyring + gpg-agent + polkit agent
#   local.keyring-services.gnomeKeyring - Run gnome-keyring (default: true)
#   local.keyring-services.pinentry - pinentry package for gpg-agent
#     (default: pkgs.pinentry-gnome3)
#   local.keyring-services.polkitAgent - Run the GNOME PolKit agent (default: true)
#   local.keyring-services.gpgKeygrip - Keygrip to auto-unlock at login
#     (default: null, disabled). Find via `gpg --list-secret-keys --with-keygrip`.
#
# Example usage:
#   local.keyring-services.enable = true;
#   local.keyring-services.polkitAgent = false;
#   local.keyring-services.gpgKeygrip = "B7108ED21D2D31BBA0036C6E7D5D9DCF0DBBA5A6";
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

    gnomeKeyring = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run gnome-keyring; disable where the desktop has its own (KWallet)";
    };

    pinentry = lib.mkOption {
      type = lib.types.package;
      default = pkgs.pinentry-gnome3;
      defaultText = lib.literalExpression "pkgs.pinentry-gnome3";
      description = "pinentry package gpg-agent uses to prompt for passphrases";
    };

    polkitAgent = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run the GNOME PolKit agent; disable where the desktop runs its own";
    };

    gpgKeygrip = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "B7108ED21D2D31BBA0036C6E7D5D9DCF0DBBA5A6";
      description = "Keygrip of the GPG key to auto-unlock into gpg-agent from the desktop secret service at login. Leave null to disable.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gnome-keyring = lib.mkIf cfg.gnomeKeyring {
      enable = true;
      components = [ "pkcs11" ];
    };

    # gnome-keyring: no restart on switch
    systemd.user.services.gnome-keyring.Unit.X-RestartIfChanged =
      lib.mkIf config.services.gnome-keyring.enable false;

    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 31536000; # 1 year
      maxCacheTtl = 31536000;
      pinentry.package = cfg.pinentry;
      extraConfig = "allow-preset-passphrase";
    };

    systemd.user.services.gpg-preset-passphrase = lib.mkIf (cfg.gpgKeygrip != null) {
      Unit = {
        Description = "Preset GPG key passphrase into gpg-agent from the desktop keyring";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        # Retry the keyring a few times, then give up rather than loop forever
        StartLimitIntervalSec = 300;
        StartLimitBurst = 5;
        X-RestartIfChanged = false;
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        # Give up on an unanswered unlock prompt
        TimeoutStartSec = 30;
        Environment = [
          "PATH=${pkgs.gnupg}/libexec:${pkgs.gnupg}/bin:${pkgs.libsecret}/bin:/run/current-system/sw/bin"
        ];
        ExecStart = "${./scripts/gpg-preset-passphrase.sh} ${cfg.gpgKeygrip}";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    systemd.user.services.polkit-gnome-authentication-agent-1 = lib.mkIf cfg.polkitAgent {
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
