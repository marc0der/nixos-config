{
  # Host name
  networking.hostName = "neomorph";

  # Wayland desktop: KDE Plasma
  local.wayland.enable = true;
  local.programs.plasma-desktop.enable = true;

  # Brave: let Zoom links launch the desktop client without a prompt
  local.brave-policies.enable = true;

  # Bluetooth: LE Audio for hearing aids
  local.bluetooth-le-audio.enable = true;

  # Security: Cyber Essentials Plus audit posture
  local.ce-plus.enable = true;

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
