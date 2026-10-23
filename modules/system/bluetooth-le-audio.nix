# Bluetooth LE Audio
#
# LE Audio (BAP, LC3, CSIP) for hearing aids and LE Audio earbuds.
# Reconnects LE Audio devices at login that connected before WirePlumber.
# Provides `hearing-aids on|off|toggle|status` to block paired hearing aids
# without powering off the adapter.
#
# Options:
#   local.bluetooth-le-audio.enable - Enable Bluetooth LE Audio
#
# Example usage:
#   local.bluetooth-le-audio.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.bluetooth-le-audio;
  leAudioInit = pkgs.writeShellApplication {
    name = "bluetooth-le-audio-init";
    runtimeInputs = with pkgs; [
      bluez
      coreutils
      gnugrep
    ];
    text = builtins.readFile ./scripts/bluetooth-le-audio-init.sh;
  };
  leAudioReconnect = pkgs.writeShellApplication {
    name = "bluetooth-le-audio-reconnect";
    runtimeInputs = with pkgs; [
      bluez
      coreutils
      gawk
      gnugrep
      pipewire
    ];
    text = builtins.readFile ./scripts/bluetooth-le-audio-reconnect.sh;
  };
  hearingAids = pkgs.writeShellApplication {
    name = "hearing-aids";
    runtimeInputs = with pkgs; [
      bluez
      coreutils
      gawk
      gnugrep
      libnotify
      systemd
    ];
    text = builtins.readFile ./scripts/hearing-aids.sh;
  };
  hearingAidsDesktop = pkgs.makeDesktopItem {
    name = "hearing-aids-toggle";
    desktopName = "Toggle Hearing Aids";
    comment = "Connect or disconnect the hearing aids";
    exec = "${lib.getExe hearingAids} toggle";
    icon = "audio-headphones";
    categories = [ "Utility" ];
  };
in
{
  options.local.bluetooth-le-audio = {
    enable = lib.mkEnableOption "Bluetooth LE Audio (BAP, LC3, CSIP)";
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.settings.General = {
      Experimental = true;
      KernelExperimental = true;
    };
    hardware.bluetooth.disabledPlugins = [ "asha" ];

    environment.systemPackages = [
      hearingAids
      hearingAidsDesktop
    ];

    # Let the active local session restart bluetooth.service for `hearing-aids on`
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "bluetooth.service" &&
            action.lookup("verb") == "restart" &&
            subject.local && subject.active) {
          return polkit.Result.YES;
        }
      });
    '';

    services.pipewire.wireplumber.extraConfig."11-bluez-le-audio" = {
      "monitor.bluez.properties" = {
        "bluez5.roles" = [ "bap_source" ];
        "bluez5.codecs" = [ "lc3" ];
      };
      "monitor.bluez.rules" = [
        {
          matches = [ { "device.name" = "~bluez_card.*"; } ];
          actions.update-props."bluez5.bap.preset" = "24_2_1";
        }
      ];
    };

    # Re-initialise the adapter once LE Audio support is on
    systemd.services.bluetooth-le-audio-init = {
      description = "Re-initialise Bluetooth adapter with LE Audio support";
      after = [ "bluetooth.service" ];
      wantedBy = [ "bluetooth.service" ];
      restartIfChanged = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = lib.getExe leAudioInit;
      };
    };

    # Reconnect LE Audio devices that connected before WirePlumber was ready
    systemd.user.services.bluetooth-le-audio-reconnect = {
      description = "Reconnect LE Audio devices missing an audio card";
      after = [ "wireplumber.service" ];
      wantedBy = [ "wireplumber.service" ];
      restartIfChanged = false;
      unitConfig.ConditionUser = "!@system";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe leAudioReconnect;
      };
    };
  };
}
