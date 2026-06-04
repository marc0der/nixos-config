# CUPS printing with Brother driver + Avahi service discovery
#
# Enables CUPS bound to localhost only (no network sharing) with the Brother
# HL-L2350DW driver and an Avahi mDNS responder so the printer is discoverable
# on the local network. The two are bundled because the printer is the only
# reason Avahi is enabled in this config.
#
# Options:
#   local.printing.enable - Enable CUPS + Brother driver + Avahi
#
# Example usage:
#   local.printing.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.printing;
in
{
  options.local.printing = {
    enable = lib.mkEnableOption "CUPS printing with Brother driver and Avahi";
  };

  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = with pkgs; [ cups-brother-hll2350dw ];
      browsing = false;
      defaultShared = false;
      listenAddresses = [ "localhost:631" ];
      allowFrom = [ "localhost" ];
      startWhenNeeded = true;
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };
  };
}
