{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b3c35abf-6585-4c53-bdee-5a7af994aa9f";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FD87-9FD2";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/luks-25dcf7b3-7d8c-490c-9f63-c06803d54906";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-25dcf7b3-7d8c-490c-9f63-c06803d54906".device =
    "/dev/disk/by-uuid/25dcf7b3-7d8c-490c-9f63-c06803d54906";

  swapDevices = [ { device = "/dev/disk/by-uuid/a2fde2e6-e74b-4edb-8b76-8ae9fa58d114"; } ];
}
