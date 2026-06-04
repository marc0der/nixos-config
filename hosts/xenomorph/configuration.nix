{
  # Host name
  networking.hostName = "xenomorph";

  # Kernel modules: SCSI generic support
  boot.kernelModules = [ "sg" ];

  # User groups: optical drive access
  users.users.marco.extraGroups = [ "cdrom" ];

  # Wayland desktop
  local.wayland.enable = true;
  local.programs.hyprland-desktop.enable = true;

  # Gaming profile
  local.profiles.gaming.enable = true;

  # Tailscale VPN
  local.services.tailscale-vpn.enable = true;

  # Power management: Suspend even when plugged in
  services.logind.settings.Login.HandleLidSwitchExternalPower = "suspend";
}
