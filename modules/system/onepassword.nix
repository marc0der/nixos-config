# 1Password with Wayland-native rendering
#
# Enables programs._1password and programs._1password-gui (with marco as a
# PolKit policy owner so CLI integration works) plus an override that wraps
# the 1password binary with Ozone Wayland flags so it renders natively under
# Wayland compositors.
#
# Options:
#   local.onepassword.enable - Enable 1Password GUI + CLI with Wayland override
#
# Example usage:
#   local.onepassword.enable = true;
{
  config,
  lib,
  ...
}:

let
  cfg = config.local.onepassword;
in
{
  options.local.onepassword = {
    enable = lib.mkEnableOption "1Password with Ozone Wayland wrapping";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.packageOverrides = pkgs: {
      _1password-gui = pkgs._1password-gui.overrideAttrs (oldAttrs: {
        postFixup = (oldAttrs.postFixup or "") + ''
          # Wrap the 1password binary to add Ozone Wayland flags
          wrapProgram $out/bin/1password \
            --add-flags "--ozone-platform-hint=auto" \
            --add-flags "--enable-features=WaylandWindowDecorations"
        '';
      });
    };

    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "marco" ];
    };
  };
}
