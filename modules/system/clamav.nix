# ClamAV antivirus module with daily scanning
#
# Options:
#   services.clamav-security.enable - Enable ClamAV antivirus with daily scans
#
# Example usage:
#   services.clamav-security.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.clamav-security;
in
{
  options.services.clamav-security = {
    enable = lib.mkEnableOption "ClamAV antivirus with daily scanning";
  };

  config = lib.mkIf cfg.enable {
    # Enable ClamAV antivirus
    services.clamav = {
      daemon.enable = true;
      updater = {
        enable = true;
        interval = "hourly"; # Update virus definitions every hour
        frequency = 24; # Check for updates 24 times per day
      };
    };

    # Create a systemd service for daily scans
    systemd.services.clamav-scan = {
      description = "ClamAV daily system scan";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.clamav}/bin/clamdscan --multiscan --fdpass --infected /home 2>&1 | grep -v \"Not supported file type\\|WARNING\" > /var/log/clamav/daily-scan.log'";
        User = "root";
      };
      # Ensure the daemon is running before scanning
      after = [ "clamav-daemon.service" ];
      requires = [ "clamav-daemon.service" ];
    };

    # Create a systemd timer to run daily scans at 3 AM
    systemd.timers.clamav-scan = {
      description = "Daily ClamAV scan timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "03:00"; # Run at 3 AM daily
        Persistent = false; # Don't run missed scans on boot
        RandomizedDelaySec = "15m"; # Add up to 15min random delay
      };
    };

    # Ensure log directory exists
    systemd.tmpfiles.rules = [ "d /var/log/clamav 0755 clamav clamav -" ];

    # Add clamav tools to system packages for manual scans
    environment.systemPackages = with pkgs; [ clamav ];
  };
}
