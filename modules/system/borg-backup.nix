# Borg Backup Module
#
# Scheduled BorgBackup of /home/marco to the Synology NAS, replacing Vorta.
# Runs as a system-level systemd timer that drops privileges to the `marco`
# user, so it backs up unattended (login-independent) while reusing marco's
# SSH key and config. The repo passphrase is provided via agenix.
#
# Repo:      ssh://synology/volume1/backups/<hostname>  (repokey, pre-existing)
# Transport: marco@NAS over SSH (id_rsa); remote borg at /usr/local/bin/borg
# Schedule:  every 3h, Persistent (catch-up on wake); prune + compact each run
#
# Options:
#   local.services.borg-backup.enable - Enable scheduled Borg backup (default: false)
#
# Example usage:
#   local.services.borg-backup.enable = true;

{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.local.services.borg-backup;
  host = config.networking.hostName;
in
{
  options.local.services.borg-backup = {
    enable = mkEnableOption "Scheduled Borg backup of /home/marco to the NAS";
  };

  config = mkIf cfg.enable {
    # Repo passphrase, decrypted to a marco-readable file at activation
    age.secrets.borg-passphrase = {
      file = ../../secrets/borg-passphrase.age;
      owner = "marco";
      group = "users";
      mode = "0400";
    };

    services.borgbackup.jobs.home = {
      paths = "/home/marco";
      repo = "ssh://synology/volume1/backups/${host}";

      # Drop to marco: reuse his key/ssh-config, own the source files
      user = "marco";
      group = "users";

      doInit = false;
      archiveBaseName = host;
      failOnWarnings = false;

      encryption = {
        mode = "repokey";
        passCommand = "cat ${config.age.secrets.borg-passphrase.path}";
      };
      compression = "lz4";

      startAt = "*-*-* 00/3:00:00";
      persistentTimer = true;

      # Remote borg lives outside the NAS's non-interactive PATH
      extraArgs = [ "--remote-path=/usr/local/bin/borg" ];

      environment = {
        BORG_RSH = "ssh -i /home/marco/.ssh/id_rsa -o BatchMode=yes -o StrictHostKeyChecking=accept-new";
        BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
      };

      prune.keep = {
        within = "7d";
        daily = 14;
        weekly = 8;
        monthly = 12;
        yearly = 3;
      };

      exclude = [
        # Ported from the previous Vorta profile
        "**/.cache/"
        "**/.cargo/"
        "**/.gradle/"
        "**/.ivy2/"
        "**/.java/"
        "**/.get_iplayer/"
        "**/.mozilla/"
        "**/.pyenv/"
        "**/.sdkman/"
        "**/target"
        "**/build"
        "**/.idea"
        "**/Videos/"
        "**/*.iso"
        "**/.var/app/"
        "**/Downloads/"

        # Narrowed .local/share: skip the big/reproducible, keep game saves
        "/home/marco/.local/share/Trash"
        "/home/marco/.local/share/Steam/steamapps/common"
        "/home/marco/.local/share/Steam/steamapps/shadercache"
        "/home/marco/.local/share/Steam/steamapps/downloading"
        "/home/marco/.local/share/Steam/steamapps/temp"
        "/home/marco/.local/share/Steam/appcache"
        "/home/marco/.local/share/docker"
        "/home/marco/.local/share/uv"
        "/home/marco/.local/share/JetBrains"

        # Regenerable app/browser/editor caches (Electron/Chromium, any depth)
        "**/Cache/"
        "**/Cache_Data/"
        "**/Code Cache/"
        "**/GPUCache/"
        "**/CachedData/"
        "**/CachedExtensionVSIXs/"
        "**/CacheStorage/"
        "**/DawnCache/"
        "**/DawnGraphiteCache/"
        "**/DawnWebGPUCache/"
        "**/GrShaderCache/"
        "**/ShaderCache/"
        "**/Crashpad/"
        "**/blob_storage/"
        "**/component_crx_cache/"
        "**/.npm/"
      ];
    };
  };
}
