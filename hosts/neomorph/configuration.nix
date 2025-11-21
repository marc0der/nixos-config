{
  networking.hostName = "neomorph";

  wayland.enable = true;

  programs.sway-desktop.enable = true;

  services.clamav-security.enable = true;

  # Never suspend when plugged in, only suspend on battery when lid is closed
  services.logind.lidSwitchExternalPower = "ignore";
}
