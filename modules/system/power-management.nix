# Power management with battery charge threshold
#
# Enables power-profiles-daemon, configures logind to suspend on lid close
# (except when docked) and ignore the power key, and installs a oneshot
# systemd service that caps the battery charge controller at 80% to slow
# battery wear on the always-plugged-in machine.
#
# Options:
#   power-management.enable - Enable power-profiles-daemon + battery cap
#
# Example usage:
#   power-management.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.power-management;
in
{
  options.power-management = {
    enable = lib.mkEnableOption "power-profiles-daemon, logind tweaks, battery cap";
  };

  config = lib.mkIf cfg.enable {
    services.power-profiles-daemon.enable = true;

    services.logind = {
      settings = {
        Login = {
          HandleLidSwitch = "suspend";
          HandleLidSwitchDocked = "ignore";
          IdleAction = "ignore";
          HandlePowerKey = "ignore";
        };
      };
    };

    systemd.services.battery-charge-threshold = {
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      startLimitBurst = 0;
      description = "Sets a battery charge end threshold";
      serviceConfig = {
        Type = "oneshot";
        Restart = "on-failure";
        ExecStart = "${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold' ";
      };
    };
  };
}
