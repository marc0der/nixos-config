# Brave Managed Policies
#
# Writes Chromium managed-policy JSON to /etc/brave/policies/managed, which
# Brave reads at startup. Used to let Zoom meeting links launch the desktop
# client straight from a browser click, with no confirmation dialog.
#
# Options:
#   local.brave-policies.enable - Enable Brave managed policies (default: false)
#   local.brave-policies.autoLaunchOrigins - Origins allowed to auto-launch
#     Zoom URL schemes without a prompt
#
# Example usage:
#   local.brave-policies.enable = true;

{
  config,
  lib,
  ...
}:

let
  cfg = config.local.brave-policies;

  schemes = [
    "zoommtg"
    "zoomus"
    "zoomphonecall"
    "zoomphonesms"
    "zoomcontactcentercall"
  ];

  policy = {
    AutoLaunchProtocolsFromOrigins = map (protocol: {
      inherit protocol;
      allowed_origins = cfg.autoLaunchOrigins;
    }) schemes;
    ExternalProtocolDialogShowAlwaysOpenCheckbox = true;
  };
in
{
  options.local.brave-policies = {
    enable = lib.mkEnableOption "Brave managed policies";

    autoLaunchOrigins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "https://zoom.us"
        "https://*.zoom.us"
        "https://zoom.com"
        "https://*.zoom.com"
        "https://calendar.google.com"
      ];
      description = "Origins allowed to auto-launch Zoom URL schemes";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."brave/policies/managed/zoom.json".text = builtins.toJSON policy;
  };
}
