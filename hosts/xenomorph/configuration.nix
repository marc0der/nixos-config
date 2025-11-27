{
  # Host name
  networking.hostName = "xenomorph";

  # Wayland desktop
  wayland.enable = true;
  programs.hyprland-desktop.enable = true;

  # Gaming profile
  profiles.gaming.enable = true;

  # Power management: Suspend even when plugged in
  services.logind.lidSwitchExternalPower = "suspend";
}
