{
  # Host name
  networking.hostName = "neomorph";

  # Wayland desktop
  local.wayland.enable = true;
  local.programs.sway-desktop.enable = true;

  # Security
  local.services.clamav-security.enable = true;

  # Virtualisation: libvirt + virt-manager (corporate VPN VM)
  local.virtualisation.libvirt.enable = true;
  local.virtualisation.libvirt.staticHosts = [
    {
      mac = "52:54:00:3f:f3:69";
      ip = "192.168.122.96";
    }
  ];

  # Power management: Never suspend when plugged in
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
}
