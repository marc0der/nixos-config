# NetworkManager and firewall
#
# Enables NetworkManager with the OpenVPN plugin plus a stateful firewall
# allowing SSH and ICMP. The two are bundled because every host that needs
# NetworkManager also needs the firewall configured the same way.
#
# Options:
#   local.networking-stack.enable - Enable NetworkManager + firewall
#
# Example usage:
#   local.networking-stack.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.networking-stack;
in
{
  options.local.networking-stack = {
    enable = lib.mkEnableOption "NetworkManager and firewall";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
      settings = {
        connectivity = {
          uri = "http://nmcheck.gnome.org/check_network_status.txt";
          interval = 60;
          enabled = true;
        };
      };
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ ];
      trustedInterfaces = [ "lo" ];
      allowPing = true;
    };
  };
}
