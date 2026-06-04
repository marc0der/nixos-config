# Google Drive bisync via rclone
#
# Runs `rclone bisync drive:Share ~/GoogleDrive` every ten minutes via a
# user-level systemd timer. Schedules are staggered across hosts (neomorph on
# the :00/10 cadence, every other host on :05/10) so two machines never push
# the same file at the same moment. The service is `Type=oneshot` and logs to
# /tmp/rclone-bisync.log.
#
# The host name is taken from `hostName` (passed in via the flake's
# extraSpecialArgs) so the schedule is determined at Nix evaluation time,
# not at unit start. Reading `config.networking.hostName` here would not
# work, because home-manager's `config` namespace has no
# `networking.hostName` option.
#
# Requires `pkgs.rclone` to be installed (via `home.packages` or globally) and
# a valid rclone config at ~/.config/rclone/rclone.conf with a `drive:` remote.
#
# Options:
#   google-drive-bisync.enable - Enable the bisync service + 10-min timer
#
# Example usage:
#   google-drive-bisync.enable = true;
{
  config,
  lib,
  pkgs,
  hostName,
  ...
}:

let
  cfg = config.google-drive-bisync;
  isNeomorph = hostName == "neomorph";
  syncSchedule = if isNeomorph then "*:00/10" else "*:05/10";
  scheduleLogStr =
    if isNeomorph then ":00,:10,:20,:30,:40,:50" else ":05,:15,:25,:35,:45,:55";
  onBoot = if isNeomorph then "2min" else "7min";
in
{
  options.google-drive-bisync = {
    enable = lib.mkEnableOption "Google Drive bisync via rclone (10-minute timer)";
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.google-drive-bisync = {
      Unit = {
        Description = "Google Drive bisync service";
        After = [ "network-online.target" ];
      };

      Service = {
        Type = "oneshot";
        Environment = [
          "RCLONE_CONFIG=%h/.config/rclone/rclone.conf"
          "PATH=/run/wrappers/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:%h/.nix-profile/bin"
        ];
        ExecStartPre = "${pkgs.writeShellScript "log-sync-start" ''
          echo "Starting GoogleDrive sync on ${hostName} (schedule: ${scheduleLogStr})"
        ''}";
        ExecStart = toString [
          "/run/current-system/sw/bin/rclone"
          "bisync"
          "drive:Share"
          "%h/GoogleDrive"
          "--resilient"
          "--create-empty-src-dirs"
          "--conflict-resolve=newer"
          "--log-file"
          "/tmp/rclone-bisync.log"
          "--log-level"
          "INFO"
        ];
        ExecStartPost = "${pkgs.writeShellScript "log-sync-end" ''
          echo "Completed GoogleDrive sync on ${hostName}"
        ''}";
      };
    };

    systemd.user.timers.google-drive-bisync = {
      Unit = {
        Description = "Run Google Drive bisync every 10 minutes (staggered)";
      };

      Timer = {
        OnBootSec = onBoot;
        OnCalendar = syncSchedule;
        Unit = "google-drive-bisync.service";
        Persistent = true;
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
