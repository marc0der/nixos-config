{
  networking.hostName = "xenomorph";

  wayland.enable = true;

  programs.hyprland-desktop.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
}
