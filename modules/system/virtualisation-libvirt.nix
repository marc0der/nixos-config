# Libvirt virtualisation module
#
# Enables libvirtd + virt-manager for running VMs (e.g. a Linux Mint
# guest hosting the corporate GlobalProtect VPN client). Adds the primary
# user to the libvirtd group so virt-manager works without sudo.
#
# Disk images are stored in a dedicated pool on /home (the root partition
# is too small), defined and autostarted declaratively.
#
# Options:
#   local.virtualisation.libvirt.enable - Enable libvirtd + virt-manager (default: false)
#
# Example usage:
#   local.virtualisation.libvirt.enable = true;
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
  };
}
