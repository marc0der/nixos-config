{
  networking.hostName = "xenomorph";

  wayland.enable = true;

  programs.hyprland-desktop.enable = true;

  profiles.gaming.enable = true;

  # Suspend even when plugged in
  services.logind.lidSwitchExternalPower = "suspend";
}
