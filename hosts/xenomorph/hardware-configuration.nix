{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b69c9bfd-2bd4-488d-84af-f19c6c0157ae";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/20DE-5824";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/bce75386-639c-49d0-b94e-cba2842f11bb";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."nvme0n1p4_crypt".device =
    "/dev/disk/by-uuid/2fed677d-3b3a-4c73-87f5-10c3b004c1cf";

  swapDevices = [ { device = "/dev/disk/by-uuid/456cab68-56b2-4fb4-816c-2c8056eb106f"; } ];
}
