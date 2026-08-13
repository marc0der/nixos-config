# Borg Backup Module
#
# Scheduled BorgBackup of /home/marco to the Synology NAS, replacing Vorta.
# Runs as a system-level systemd timer that drops privileges to the `marco`
# user, so it backs up unattended (login-independent) while reusing marco's
# SSH key and config. The repo passphrase is provided via agenix.
#
# Repo:      ssh://ds218j.<tailnet>.ts.net/volume1/backups/<hostname>  (repokey)
# Transport: marco@NAS over SSH (id_rsa) via Tailscale; remote borg at
#            /usr/local/bin/borg. Direct on the home LAN, relay when away.
# Schedule:  every 3h, Persistent (catch-up on wake); prune + compact each run
#            Staggered per host via startAt so hosts don't hit the NAS at once
# Network:   skips cleanly on metered connections (ExecCondition)
# Monitor:   Healthchecks.io dead-man's-switch (/start, success, /fail pings)
# Secrets:   borg-passphrase-<hostname>.age, healthchecks-<hostname>.age
#
# Options:
#   local.services.borg-backup.enable  - Enable scheduled Borg backup (default: false)
#   local.services.borg-backup.startAt - Timer schedule (default: "*-*-* 00/3:00:00")
#
# Example usage:
#   local.services.borg-backup.enable = true;
#   local.services.borg-backup.startAt = "*-*-* 01/3:30:00";

{
  config,
  lib,
  pkgs,
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

    startAt = mkOption {
      type = types.str;
      default = "*-*-* 00/3:00:00";
      example = "*-*-* 01/3:30:00";
      description = "Timer schedule (OnCalendar). Stagger across hosts so they don't hit the NAS at once.";
    };
  };

  config = mkIf cfg.enable {
    # Repo passphrase, decrypted to a marco-readable file at activation
    age.secrets.borg-passphrase = {
      file = ../../secrets/borg-passphrase-${host}.age;
      owner = "marco";
      group = "users";
      mode = "0400";
    };

    # Healthchecks.io dead-man's-switch ping URL (capability secret)
    age.secrets.healthchecks-url = {
      file = ../../secrets/healthchecks-${host}.age;
      owner = "marco";
      group = "users";
      mode = "0400";
    };

    services.borgbackup.jobs.home = {
      paths = "/home/marco";
      # Reached over Tailscale MagicDNS: direct on the home LAN, relay when away
      repo = "ssh://ds218j.zonkey-ulmer.ts.net/volume1/backups/${host}";

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

      # Healthchecks dead-man's-switch: /start on begin, success on completion
      # (postHook only runs when the whole job succeeds under `set -e`)
      preHook = ''
        ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "$(cat ${config.age.secrets.healthchecks-url.path})/start" || true
      '';
      postHook = ''
        ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "$(cat ${config.age.secrets.healthchecks-url.path})" || true
      '';

      startAt = cfg.startAt;
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

    # Spread simultaneous catch-up runs across hosts after downtime
    systemd.timers."borgbackup-job-home".timerConfig.RandomizedDelaySec = "10m";

    # Ping Healthchecks /fail when the backup unit fails
    systemd.services.borgbackup-hc-fail = {
      description = "Ping Healthchecks /fail for borg backup";
      serviceConfig = {
        Type = "oneshot";
        User = "marco";
        Group = "users";
      };
      script = ''
        ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "$(cat ${config.age.secrets.healthchecks-url.path})/fail" || true
      '';
    };
    systemd.services."borgbackup-job-home".onFailure = [ "borgbackup-hc-fail.service" ];

    # Skip cleanly (recorded as skipped, not failed) on a metered connection
    systemd.services."borgbackup-job-home".serviceConfig.ExecCondition =
      pkgs.writeShellScript "borg-skip-metered" ''
        raw=$(${pkgs.systemd}/bin/busctl get-property org.freedesktop.NetworkManager \
          /org/freedesktop/NetworkManager org.freedesktop.NetworkManager Metered 2>/dev/null)
        # NetworkManager Metered enum: 1=yes 3=guess-yes (skip); 0/2/4 = run
        case "''${raw##* }" in
          1|3) echo "metered connection, skipping backup"; exit 1 ;;
          *) exit 0 ;;
        esac
      '';
  };
}
