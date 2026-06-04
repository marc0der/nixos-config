{
  # Host name
  networking.hostName = "neomorph";

  # Wayland desktop
  local.wayland.enable = true;
  local.programs.sway-desktop.enable = true;

  # Security
  local.services.clamav-security.enable = true;

  # Power management: Never suspend when plugged in
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
}
