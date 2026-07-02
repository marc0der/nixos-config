# Libvirt virtualisation module
#
# Enables libvirtd + virt-manager for running VMs (e.g. a Linux Mint
# guest hosting the corporate GlobalProtect VPN client). Adds the primary
# user to the libvirtd group so virt-manager works without sudo.
#
# Options:
#   local.virtualisation.libvirt.enable - Enable libvirtd + virt-manager (default: false)
#
# Example usage:
#   local.virtualisation.libvirt.enable = true;
{
  config,
  lib,
  ...
}:

let
  cfg = config.local.virtualisation.libvirt;
in
{
  options.local.virtualisation.libvirt = {
    enable = lib.mkEnableOption "libvirtd and virt-manager";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    users.users.marco.extraGroups = [ "libvirtd" ];
  };
}
