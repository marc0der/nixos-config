# PipeWire audio with Bluetooth codec tuning
#
# Replaces PulseAudio with PipeWire (ALSA, JACK, and PulseAudio compatibility
# layers all on) and tunes the Wireplumber BlueZ monitor for the full set of
# headset roles and high-quality codecs (aptX HD, LDAC, AAC, SBC XQ, etc.).
# `security.rtkit.enable` is bundled because PipeWire requires it for
# realtime-priority audio threads.
#
# Options:
#   local.audio-pipewire.enable - Enable PipeWire + tuned Bluetooth audio
#
# Example usage:
#   local.audio-pipewire.enable = true;
{
  config,
  lib,
  ...
}:

let
  cfg = config.local.audio-pipewire;
in
{
  options.local.audio-pipewire = {
    enable = lib.mkEnableOption "PipeWire audio with Bluetooth codec tuning";
  };

  config = lib.mkIf cfg.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    services.pipewire.wireplumber.extraConfig."10-bluez" = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [
          "hsp_hs"
          "hsp_ag"
          "hfp_hf"
          "hfp_ag"
          "a2dp_sink"
          "a2dp_source"
        ];
        "bluez5.codecs" = [
          "bc"
          "sbc_xq"
          "aac"
          "ldac"
          "aptx"
          "aptx_hd"
          "aptx_ll"
        ];
      };
    };
  };
}
