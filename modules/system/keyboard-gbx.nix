# xkb layout with literal backtick (gbx)
#
# Enables the X server and registers a custom xkb layout "gbx" that inherits
# the standard UK extended layout but restores a literal backtick on the TLDE
# key. The default `gb(extd)` makes TLDE a dead_grave key, which does not
# compose reliably in Wayland terminals like Ghostty.
#
# Options:
#   keyboard-gbx.enable - Enable xserver + gbx layout
#
# Example usage:
#   keyboard-gbx.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.keyboard-gbx;
in
{
  options.keyboard-gbx = {
    enable = lib.mkEnableOption "xserver with gbx (UK + literal backtick) layout";
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      xkb = {
        layout = "gbx";
        extraLayouts.gbx = {
          description = "English (UK, extended, literal backtick)";
          languages = [ "eng" ];
          # Inherits gb(extd) for AltGr accents but restores the literal
          # backtick on TLDE (extd makes it a dead_grave key, which doesn't
          # compose reliably in Wayland terminals like Ghostty).
          symbolsFile = pkgs.writeText "gbx-symbols" ''
            default partial alphanumeric_keys
            xkb_symbols "basic" {
              include "gb(extd)"
              name[Group1]="English (UK, extended, literal backtick)";
              key <TLDE> { [ grave, notsign, brokenbar, NoSymbol ] };
            };
          '';
        };
      };
    };
  };
}
