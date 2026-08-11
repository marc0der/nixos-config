# SiriusXM shell proxy
#
# Opt-in `sxm-proxy` zsh function that routes the current shell (curl, git,
# sbt/Java) through the GlobalProtect VM's tinyproxy, so SiriusXM projects
# can reach the corporate VPN. Off by default and never global: it only
# takes effect in shells where you run it.
#
# Options:
#   local.sxm-proxy.enable - Add the sxm-proxy shell function (default: false)
#
# Usage:
#   sxm-proxy on       # route this shell through the VPN proxy
#   sxm-proxy off      # revert
#   sxm-proxy status   # show current state
#   pi-sxm             # launch Pi on the SiriusXM LiteLLM gateway
#
# Also writes ~/.config/sxm/foxyproxy.json for import into FoxyProxy in the
# Brave SiriusXM profile, so the browser proxy tracks the same IP.
#
# Example usage:
#   local.sxm-proxy.enable = true;
{
  config,
  lib,
  ...
}:

let
  cfg = config.local.sxm-proxy;
  vmIp = "192.168.122.96";
  port = "8888";
in
{
  options.local.sxm-proxy = {
    enable = lib.mkEnableOption "sxm-proxy shell function";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.initContent = ''
      # Route the current shell through the SiriusXM VPN proxy (opt-in)
      sxm-proxy() {
        local vm_ip=${vmIp} port=${port}
        case "''${1:-on}" in
          on)
            export VM_IP=$vm_ip
            export http_proxy="http://$vm_ip:$port"
            export https_proxy="$http_proxy"
            export HTTP_PROXY="$http_proxy"
            export HTTPS_PROXY="$http_proxy"
            export no_proxy="localhost,127.0.0.1"
            export NO_PROXY="$no_proxy"
            # Node 24+ fetch honors proxy env only when this is set
            export NODE_USE_ENV_PROXY=1
            export _SXM_JAVA_OPTS_BAK="''${_SXM_JAVA_OPTS_BAK-$JAVA_OPTS}"
            export JAVA_OPTS="''${_SXM_JAVA_OPTS_BAK:+$_SXM_JAVA_OPTS_BAK }-Dhttp.proxyHost=$vm_ip -Dhttp.proxyPort=$port -Dhttps.proxyHost=$vm_ip -Dhttps.proxyPort=$port"
            echo "SXM proxy ON ($vm_ip:$port)"
            ;;
          off)
            unset VM_IP http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY NODE_USE_ENV_PROXY
            if [ -n "''${_SXM_JAVA_OPTS_BAK+x}" ]; then
              export JAVA_OPTS="$_SXM_JAVA_OPTS_BAK"
              unset _SXM_JAVA_OPTS_BAK
              [ -z "$JAVA_OPTS" ] && unset JAVA_OPTS
            fi
            echo "SXM proxy OFF"
            ;;
          status)
            if [ -n "''${http_proxy:-}" ]; then
              echo "SXM proxy ON ($http_proxy)"
            else
              echo "SXM proxy OFF"
            fi
            ;;
          *)
            echo "usage: sxm-proxy [on|off|status]"
            ;;
        esac
      }

      # Launch Pi on the SiriusXM LiteLLM gateway (proxy scoped to the subshell)
      pi-sxm() {
        ( sxm-proxy on >/dev/null; exec pi --provider litellm --model claude-opus-4-8 "$@" )
      }
    '';

    # FoxyProxy import file for the Brave SiriusXM profile
    xdg.configFile."sxm/foxyproxy.json".text = builtins.toJSON {
      mode = "${vmIp}:${port}";
      sync = false;
      autoBackup = false;
      passthrough = "localhost, 127.0.0.1, ::1";
      theme = "";
      container = { };
      commands = { };
      data = [
        {
          active = true;
          title = "SiriusXM VPN";
          type = "http";
          hostname = vmIp;
          inherit port;
          username = "";
          password = "";
          cc = "";
          city = "";
          color = "#1f6feb";
          pac = "";
          pacString = "";
          proxyDNS = true;
          include = [ ];
          exclude = [ ];
          tabProxy = [ ];
        }
      ];
    };
  };
}
