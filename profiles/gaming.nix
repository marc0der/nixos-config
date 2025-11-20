# Gaming Profile Module
#
# This module provides gaming-related system configuration, primarily
# for Steam and associated gaming features.
#
# Features:
# - Steam with all firewall exceptions for multiplayer gaming
# - Remote Play support
# - Dedicated server support
# - Local network game transfers
#
# Options:
#   profiles.gaming.enable - Enable gaming profile (default: false)
#
# Example usage:
#   profiles.gaming.enable = true;

{ config, lib, ... }:

with lib;

let
  cfg = config.profiles.gaming;
in
{
  options.profiles.gaming = {
    enable = mkEnableOption "gaming profile with Steam and related features";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}
