{
  config,
  lib,
  pkgs,
  ...
}:

{
  networking.hostName = "neomorph";

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
}

