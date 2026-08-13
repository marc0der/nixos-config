{
  # Host name
  networking.hostName = "neomorph";

  # Wayland desktop
  local.wayland.enable = true;
  local.programs.sway-desktop.enable = true;

  # Security
  local.services.clamav-security.enable = true;

  # Tailscale VPN
  local.services.tailscale-vpn.enable = true;

  # Borg backup to NAS: offset 90min from xenomorph's 00/3:00 schedule
  local.services.borg-backup.enable = true;
  local.services.borg-backup.startAt = "*-*-* 01/3:30:00";

  # Virtualisation: libvirt + virt-manager (corporate VPN VM)
  local.virtualisation.libvirt.enable = true;
  local.virtualisation.libvirt.staticHosts = [
    {
      mac = "52:54:00:4e:fc:c1";
      ip = "192.168.122.96";
    }
  ];

  # Power management: Never suspend when plugged in
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
}
