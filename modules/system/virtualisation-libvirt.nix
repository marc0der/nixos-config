# Libvirt virtualisation module
#
# Enables libvirtd + virt-manager for running VMs (e.g. a Lubuntu
# guest hosting the corporate GlobalProtect VPN client). Adds the primary
# user to the libvirtd group so virt-manager works without sudo.
#
# The default NAT network is started and autostarted declaratively so guest
# connectivity survives a reinstall.
#
# Disk images are stored in a dedicated pool on /home (the root partition
# is too small), defined and autostarted declaratively.
#
# Options:
#   local.virtualisation.libvirt.enable      - Enable libvirtd + virt-manager (default: false)
#   local.virtualisation.libvirt.staticHosts - Static DHCP reservations on the default network (default: [])
#
# Example usage:
#   local.virtualisation.libvirt.enable = true;
#   local.virtualisation.libvirt.staticHosts = [
#     { mac = "52:54:00:3f:f3:69"; ip = "192.168.122.96"; }
#   ];
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.virtualisation.libvirt;
  poolName = "vms";
  poolPath = "/home/vms";
in
{
  options.local.virtualisation.libvirt = {
    enable = lib.mkEnableOption "libvirtd and virt-manager";

    staticHosts = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            mac = lib.mkOption {
              type = lib.types.str;
              description = "Guest NIC MAC address.";
            };
            ip = lib.mkOption {
              type = lib.types.str;
              description = "Fixed IPv4 address to reserve on the default network.";
            };
          };
        }
      );
      default = [ ];
      description = "Static DHCP reservations on the libvirt default network.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    users.users.marco.extraGroups = [ "libvirtd" ];

    # VM disk storage on /home (root partition is too small)
    systemd.tmpfiles.rules = [
      "d ${poolPath} 0711 root root -"
    ];

    # Define + autostart the storage pool on the system libvirt connection
    systemd.services.libvirt-pool-vms = {
      description = "Ensure libvirt '${poolName}' storage pool on ${poolPath}";
      after = [ "libvirtd.service" ];
      requires = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];
      environment.LIBVIRT_DEFAULT_URI = "qemu:///system";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        set -eu
        virsh=${pkgs.libvirt}/bin/virsh
        if ! $virsh pool-uuid ${poolName} >/dev/null 2>&1; then
          $virsh pool-define-as ${poolName} dir --target ${poolPath}
        fi
        $virsh pool-autostart ${poolName}
        $virsh pool-start ${poolName} 2>/dev/null || true
      '';
    };

    # Start + autostart the default NAT network
    systemd.services.libvirt-net-default = {
      description = "Ensure the libvirt default network is started and autostarted";
      after = [ "libvirtd.service" ];
      requires = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];
      environment.LIBVIRT_DEFAULT_URI = "qemu:///system";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        set -eu
        virsh=${pkgs.libvirt}/bin/virsh
        $virsh net-autostart default
        $virsh net-start default 2>/dev/null || true
      '';
    };

    # Pin guest IPs via static DHCP reservations on the default network
    systemd.services.libvirt-net-reservations = lib.mkIf (cfg.staticHosts != [ ]) {
      description = "Ensure static DHCP reservations on the libvirt default network";
      after = [ "libvirt-net-default.service" ];
      requires = [ "libvirt-net-default.service" ];
      wantedBy = [ "multi-user.target" ];
      environment.LIBVIRT_DEFAULT_URI = "qemu:///system";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script =
        let
          entries = lib.concatMapStringsSep "\n" (h: ''
            if ! "$virsh" net-dumpxml default | grep -q "${h.mac}"; then
              "$virsh" net-update default add ip-dhcp-host "<host mac='${h.mac}' ip='${h.ip}'/>" --config $live
            fi
          '') cfg.staticHosts;
        in
        ''
          set -eu
          virsh=${pkgs.libvirt}/bin/virsh
          live=""
          if "$virsh" net-info default | grep -qi '^Active: *yes'; then
            live="--live"
          fi
          ${entries}
        '';
    };
  };
}
