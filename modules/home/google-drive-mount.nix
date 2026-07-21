# Google Drive Shared Drive mount via rclone
#
# Mounts the SiriusXM Shared Drive (`sxm:` remote) at ~/SharedDrives/Workspace
# as a FUSE filesystem with a full VFS cache, so the team drive behaves like
# Dropbox smart-sync: files stream on demand, local writes upload within
# seconds, and other people's changes appear within the poll interval (~30s).
#
# Unlike google-drive-bisync (a timer-driven two-way copy of a personal drive),
# this is a live cloud-backed mount, which avoids sync conflicts when many
# people edit the same Shared Drive concurrently.
#
# Requires:
#   - pkgs.rclone installed (globally in configuration.nix)
#   - FUSE enabled on the host (programs.fuse + boot.supportedFilesystems)
#   - an rclone remote named `sxm` (type=drive, team_drive set) in
#     ~/.config/rclone/rclone.conf
#
# Options:
#   local.google-drive-mount.enable - Enable the Shared Drive mount service
#
# Example usage:
#   local.google-drive-mount.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.google-drive-mount;
  remote = "sxm:";
  mountPoint = "%h/SharedDrives/Workspace";
in
{
  options.local.google-drive-mount = {
    enable = lib.mkEnableOption "Google Drive Shared Drive mount via rclone";
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.google-drive-mount = {
      Unit = {
        Description = "Google Drive Shared Drive mount (rclone)";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "notify";
        Environment = [
          "RCLONE_CONFIG=%h/.config/rclone/rclone.conf"
          "PATH=/run/wrappers/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:%h/.nix-profile/bin"
        ];
        ExecStartPre = "/run/current-system/sw/bin/mkdir -p ${mountPoint}";
        ExecStart = toString [
          "/run/current-system/sw/bin/rclone"
          "mount"
          remote
          mountPoint
          "--vfs-cache-mode"
          "full"
          "--vfs-cache-max-size"
          "10G"
          "--vfs-cache-max-age"
          "168h"
          "--vfs-write-back"
          "5s"
          "--dir-cache-time"
          "1000h"
          "--poll-interval"
          "30s"
          "--vfs-fast-fingerprint"
          "--log-file"
          "/tmp/rclone-mount-workspace.log"
          "--log-level"
          "INFO"
        ];
        ExecStop = "/run/wrappers/bin/fusermount3 -u ${mountPoint}";
        Restart = "on-failure";
        RestartSec = "10";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
