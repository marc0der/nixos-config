{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "i915.force_probe=7d45" ];
  boot.kernel.sysctl = { "vm.swappiness" = 0; };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b3c35abf-6585-4c53-bdee-5a7af994aa9f";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FD87-9FD2";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/3ab912d9-130b-4b23-a89e-a423119a9c2f";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-25dcf7b3-7d8c-490c-9f63-c06803d54906".device =
    "/dev/disk/by-uuid/25dcf7b3-7d8c-490c-9f63-c06803d54906";

  swapDevices =
    [{ device = "/dev/disk/by-uuid/a2fde2e6-e74b-4edb-8b76-8ae9fa58d114"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ intel-media-driver vpl-gpu-rt ];
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = { General = { Enable = "Source,Sink,Media,Socket"; }; };
  };
}
