# Google Drive team-drive local sync (rclone bisync)
#
# Keeps the SiriusXM Shared Drive (`sxm:` remote) mirrored to a real local
# folder at ~/SharedDrives/Workspace, so all file operations are native
# disk speed. Changes sync to the share asynchronously (local-first):
#
#   - a 3-minute timer pulls teammates' changes
#   - an inotify watcher nudges a sync shortly after local edits settle
#
# Both triggers invoke the same oneshot bisync service (a flock in the sync
# script and systemd's single-instance semantics keep runs from overlapping).
# --fast-list keeps each run cheap: it pages the whole tree in ~2 API calls
# instead of walking every folder. A full sync still takes ~1 minute because
# Drive listing dominates, so a change crosses machines in ~1-3 minutes.
# This replaces the earlier FUSE mount, which was slow on a drive with many
# small files because every metadata op round-tripped to Drive.
#
# Requires:
#   - pkgs.rclone (global) and pkgs.inotify-tools (added below)
#   - an rclone remote named `sxm` (type=drive, team_drive set)
#
# Options:
#   local.google-drive-workspace.enable - Enable the sync service, timer, and watcher
#
# Example usage:
#   local.google-drive-workspace.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.google-drive-workspace;
  path = "/run/wrappers/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:%h/.nix-profile/bin";
in
{
  options.local.google-drive-workspace = {
    enable = lib.mkEnableOption "Google Drive team-drive local sync via rclone bisync";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.inotify-tools ];

    home.file."bin/gdrive-workspace-sync" = {
      source = ./scripts/gdrive-workspace-sync.sh;
      executable = true;
    };
    home.file."bin/gdrive-workspace-watch" = {
      source = ./scripts/gdrive-workspace-watch.sh;
      executable = true;
    };

    systemd.user.services.gdrive-workspace-sync = {
      Unit = {
        Description = "Sync SiriusXM team drive with ~/SharedDrives/Workspace";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        Environment = [
          "RCLONE_CONFIG=%h/.config/rclone/rclone.conf"
          "PATH=${path}"
        ];
        ExecStart = "%h/bin/gdrive-workspace-sync";
      };
    };

    systemd.user.timers.gdrive-workspace-sync = {
      Unit = {
        Description = "Pull SiriusXM team drive changes every 3 minutes";
      };
      Timer = {
        OnBootSec = "1min";
        OnCalendar = "*:0/3";
        Unit = "gdrive-workspace-sync.service";
        Persistent = true;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };

    systemd.user.services.gdrive-workspace-watch = {
      Unit = {
        Description = "Watch ~/SharedDrives/Workspace and push edits to the team drive";
        After = [ "network-online.target" ];
      };
      Service = {
        Environment = [ "PATH=${path}" ];
        ExecStart = "%h/bin/gdrive-workspace-watch";
        Restart = "on-failure";
        RestartSec = "10";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
