# Tailscale VPN module
#
# Enables Tailscale mesh VPN with firewall rules.
#
# Options:
#   local.services.tailscale-vpn.enable - Enable Tailscale VPN (default: false)
#
# Example usage:
#   local.services.tailscale-vpn.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.services.tailscale-vpn;
in
{
  options.local.services.tailscale-vpn = {
    enable = lib.mkEnableOption "Tailscale VPN";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;

    # Allow Tailscale traffic through the firewall
    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}
