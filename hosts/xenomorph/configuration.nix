{
  # Host name
  networking.hostName = "xenomorph";

  # Kernel modules: SCSI generic support
  boot.kernelModules = [ "sg" ];

  # User groups: optical drive access
  users.users.marco.extraGroups = [ "cdrom" ];

  # Wayland desktop
  wayland.enable = true;
  programs.hyprland-desktop.enable = true;

  # Gaming profile
  profiles.gaming.enable = true;

  # Power management: Suspend even when plugged in
  services.logind.settings.Login.HandleLidSwitchExternalPower = "suspend";
}
