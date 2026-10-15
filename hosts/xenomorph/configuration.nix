{
  # Host name
  networking.hostName = "xenomorph";

  # Wayland desktop
  local.wayland.enable = true;
  local.programs.hyprland-desktop.enable = true;

  # Security: unlock gnome-keyring at SDDM login
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Gaming profile
  local.profiles.gaming.enable = true;

  # Tailscale VPN
  local.services.tailscale-vpn.enable = true;

  # Borg backup to NAS
  local.services.borg-backup.enable = true;

  # Power management: Suspend even when plugged in
  services.logind.settings.Login.HandleLidSwitchExternalPower = "suspend";
}
