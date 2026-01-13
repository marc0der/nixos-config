{
  # Host name
  networking.hostName = "neomorph";

  # Wayland desktop
  wayland.enable = true;
  programs.sway-desktop.enable = true;

  # Security
  services.clamav-security.enable = true;

  # Power management: Never suspend when plugged in
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
}
