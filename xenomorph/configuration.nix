{
  config,
  lib,
  pkgs,
  ...
}:

{
  networking.hostName = "neomorph";

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  programs.hyprlock.enable = true;

  security.pam.services.hyprlock = { };

}

